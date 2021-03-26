#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export APP_NAME=$(get_env app-name)
cd $WORKSPACE

GH_TOKEN=$(cat "./git-token")
if [ ! -d $APP_NAME ]; then
    # check branch protection and clone app repo
    APP_REPO_URL=$(get_env repository)
    APP_REPO_URL=${APP_REPO_URL%.git}
    OWNER=${APP_REPO_URL%/*}
    OWNER=${OWNER##*/}
    REPO_NAME=${APP_REPO_URL##*/}
    REPO_BRANCH=$(get_env branch)
    curl -u ":$GH_TOKEN" https://github.ibm.com/api/v3/repos/$OWNER/$REPO_NAME/branches/$REPO_BRANCH/protection -XPUT -d '{"required_pull_request_reviews":{"dismiss_stale_reviews":true},"required_status_checks":{"strict":true,"contexts":["tekton/code-branch-protection","tekton/code-unit-tests","tekton/code-cis-check","tekton/code-vulnerability-scan","tekton/code-detect-secrets"]},"enforce_admins":null,"restrictions":null}'
    git clone -b $REPO_BRANCH https://$GH_TOKEN@github.ibm.com/$OWNER/$REPO_NAME $APP_NAME
fi
cd $APP_NAME

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

# cleanup
if [ -d "$WORKSPACE/$APP_NAME/otc-deploy" ]; then
    rm -rf "$WORKSPACE/$APP_NAME/otc-deploy"
fi
if [ -d "$WORKSPACE/$APP_NAME/otc-cf-deploy" ]; then
    rm -rf "$WORKSPACE/$APP_NAME/otc-cf-deploy"
fi

echo cat .pipeline_build_id
cat .pipeline_build_id
echo

echo pwd
pwd
echo

echo ls -la $WORKSPACE
ls -la $WORKSPACE
echo

echo ls -la $WORKSPACE/$APP_NAME
ls -la $WORKSPACE/$APP_NAME
echo