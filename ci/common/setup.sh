#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $COMMON_FOLDER/helpers.sh
REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE/$REPO_FOLDER

export APP_NAME=$(get_env app-name)

GH_TOKEN=$(cat "$WORKSPACE/git-token")

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

# cleanup otc-deploy so that cra doesn't consider it
cleanupOtcDeploy