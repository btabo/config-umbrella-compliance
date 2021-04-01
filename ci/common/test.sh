#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE/$REPO_FOLDER

export APP_NAME=$(get_env app-name)

# debug
echo "load_repo app-repo branch=$(load_repo app-repo branch)"
echo "load_repo app-repo url=$(load_repo app-repo url)"

# secrets
export CLOUDANT_IAM_API_KEY=$(get_env otc_CLOUDANT_IAM_API_KEY)
export test_tiam_secret=$(get_env otc_test_tiam_secret)
export ARTIFACTORY_AUTH_BASE64="$(get_env otc_ARTIFACTORY_AUTH_BASE64 "")"

# config
export CLOUDANT_URL="https://b3a94817-edbc-4fc2-8c47-33d3752bc6a0-bluemix.cloudantnosqldb.appdomain.cloud/"
export DOMAIN=stage1.ng.bluemix.net
export LOGICAL_APP_NAME=$APP_NAME
export APP_HOSTNAME_STEM=$APP_NAME
export APP_MEMORY=128M
export services__otc_api=http://nock-localhost:3400/api/v1
export services__otc_ui=http://nock-localhost:3100/devops
export TIAM_URL=https://nock-devops-api.stage1.ng.bluemix.net:443/v1/identity
export test_tiam_id=test

# secrets and config specific to the component
if [ -f "$COMMON_FOLDER/../$APP_NAME/test_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/test_config.sh
fi

# run tests
if [ "$TESTS_SCRIPT_FILE" ]; then
    chmod u+x $TESTS_SCRIPT_FILE
    if ! $TESTS_SCRIPT_FILE; then
        echo "Tests failed"
        exit 1
    fi
else
    echo "Skipping tests since TESTS_SCRIPT_FILE is not set"
fi

# cleanup
if [ -d "$WORKSPACE/$REPO_FOLDER/otc-deploy" ]; then
    rm -rf "$WORKSPACE/$REPO_FOLDER/otc-deploy"
fi
if [ -d "$WORKSPACE/$REPO_FOLDER/otc-cf-deploy" ]; then
    rm -rf "$WORKSPACE/$REPO_FOLDER/otc-cf-deploy"
fi

echo pwd
pwd
echo

echo ls -la $WORKSPACE
ls -la $WORKSPACE
echo

echo ls -la $WORKSPACE/$REPO_FOLDER
ls -la $WORKSPACE/$REPO_FOLDER
echo