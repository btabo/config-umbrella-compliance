#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

PIPELINE_TYPE=$1 #CI, PR, or CC
export APP_NAME=$2
REPO_FOLDER=$3

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $COMMON_FOLDER/../../helpers.sh

if [ -z $APP_NAME ]; then
    export APP_NAME=$(get_env app-name)
fi
if [ -z $REPO_FOLDER ]; then
    REPO_FOLDER=$(load_repo app-repo path)
fi
cd $WORKSPACE/$REPO_FOLDER

function ciSetup() {
    if [ -f $COMMON_FOLDER/../$APP_NAME/setup.sh ]; then
        source $COMMON_FOLDER/../$APP_NAME/setup.sh
        return $?
    fi

    GH_TOKEN=$(get_env git-token)

    # secrets
    export ARTIFACTORY_API_KEY="$(get_env otc_ARTIFACTORY_API_KEY)"
    if [[ "$OSTYPE" != "darwin"* ]]; then # if not on MacOS
        base64Args="-w 0" # -w 0 to disable line wrapping
    fi
    export ARTIFACTORY_TOKEN_BASE64="$( echo -n $ARTIFACTORY_API_KEY | base64 $base64Args )"
    export ARTIFACTORY_AUTH_BASE64="$(get_env otc_ARTIFACTORY_AUTH_BASE64 "")"
    export IDS_TOKEN=$GH_TOKEN

    # config
    export IDS_USER=idsorg
    export GIT_COMMIT=$(git rev-parse HEAD)
    export ARTIFACTORY_ID=idsorg@us.ibm.com

    # secrets and config specific to the component
    if [ -f "$COMMON_FOLDER/../$APP_NAME/setup_config.sh" ]; then
        . $COMMON_FOLDER/../$APP_NAME/setup_config.sh
    fi

    # save cra-custom-script-path (if not running CC, see ./cc/setup.sh)
    if [ "$CRA_CUSTOM_SCRIPT_PATH" ] && [ "$PIPELINE_TYPE" != "CC" ]; then
        echo "set_env cra-custom-script-path $CRA_CUSTOM_SCRIPT_PATH"
        set_env cra-custom-script-path $CRA_CUSTOM_SCRIPT_PATH
        echo
    fi

    # add 2 labels on each incident found by the scans: "squad:umbrella" and "<app-name>"
    # (if not running CC, see ../helpers.sh#loopThroughApps())
    if [ "$PIPELINE_TYPE" != "CC" ]; then
        echo "set_env incident-labels \"squad:umbrella,$APP_NAME\""
        set_env incident-labels "squad:umbrella,$APP_NAME"
        echo
    fi

    # run setup
    if [ "$SETUP_SCRIPT_FILE" ]; then
        chmod u+x $SETUP_SCRIPT_FILE
        if ! $SETUP_SCRIPT_FILE; then
            echo "Setup failed"
            return 1
        fi
    else
        echo "Skipping setup since SETUP_SCRIPT_FILE is not set"
    fi
    echo

    if [ "$PIPELINE_TYPE" == "CI" ]; then
        # run pii
        echo "Running PII"
        echo
        if [ -z "$TOOLCHAIN_DATA_PATH" ]; then
            echo "Setting TOOLCHAIN_DATA_PATH to /toolchain/toolchain.json"
            TOOLCHAIN_DATA_PATH="/toolchain/toolchain.json"
            echo
        fi
        export TOOLCHAIN_ID=$(jq -r '.toolchain_guid' $TOOLCHAIN_DATA_PATH)
        export REGION=$(jq -r '.region_id' $TOOLCHAIN_DATA_PATH | awk -F: '{print $3}')
        export RESOURCE_GROUP=$(jq -r 'select(.container.type=="resource_group_id") | .container.guid' $TOOLCHAIN_DATA_PATH)
        export PIPELINE_TOOLCHAIN_ID=$TOOLCHAIN_ID
        git clone --depth 1 "https://$IDS_TOKEN@github.ibm.com/org-ids/pii"
        echo "Done"
        echo
        pii/run
        echo
        echo "Done running PII"
        echo
    fi

    # cleanup otc-deploy so that cra doesn't consider it
    cleanupOtcDeploy
}

ciSetup