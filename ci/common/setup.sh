#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export APP_NAME=$(get_env app-name)
if [ -f $COMMON_FOLDER/../$APP_NAME/setup.sh ]; then
    source $COMMON_FOLDER/../$APP_NAME/setup.sh
    exit 0
fi

source $COMMON_FOLDER/helpers.sh
REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE/$REPO_FOLDER

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

# run setup
if [ "$SETUP_SCRIPT_FILE" ]; then
    chmod u+x $SETUP_SCRIPT_FILE
    if ! $SETUP_SCRIPT_FILE; then
        echo "Setup failed"
        exit 1
    fi
else
    echo "Skipping setup since SETUP_SCRIPT_FILE is not set"
fi
echo

echo "ONE_PIPELINE_PATH=$ONE_PIPELINE_PATH"

if [ "$ONE_PIPELINE_PATH" == "ci/.one-pipeline.yaml" ]; then
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