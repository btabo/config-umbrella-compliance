#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export APP_NAME=$(get_env app-name)
if [ -f $COMMON_FOLDER/../$APP_NAME/test.sh ]; then
    source $COMMON_FOLDER/../$APP_NAME/test.sh
    exit $?
fi

source $COMMON_FOLDER/helpers.sh
REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE/$REPO_FOLDER

# secrets
export CLOUDANT_IAM_API_KEY=$(get_env otc_CLOUDANT_IAM_API_KEY)
export test_tiam_secret=$(get_env otc_test_tiam_secret)
export ARTIFACTORY_AUTH_BASE64="$(get_env otc_ARTIFACTORY_AUTH_BASE64 "")"

# config
export CLOUDANT_URL="https://3972fdbd-33a6-4174-a595-e54fb1a52e56-bluemix.cloudantnosqldb.appdomain.cloud/"
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

function unitTests() {
    if [ "$TESTS_SCRIPT_FILE" ]; then
        # clone otc-deploy as it is needed by some tests
        cloneOtcDeploy

        chmod u+x $TESTS_SCRIPT_FILE
        if ! $TESTS_SCRIPT_FILE; then
            echo "Tests failed"
            echo
            cleanupOtcDeploy
            return 1
        else
            echo
            cleanupOtcDeploy
        fi
    else
        echo "Skipping tests since TESTS_SCRIPT_FILE is not set"
        echo
    fi
    return 0
}

# run unit tests
exit_code=0
unitTests || exit_code=$?

# save status for new evidence collection
status="success"
if [ "$exit_code" != "0" ]; then
    status="failure"
fi

# collect evidences, use unsupported tool-type format, this won't create any issues
collect-evidence \
    --tool-type "umbrella-unit-tests" \
    --status "$status" \
    --evidence-type "com.ibm.unit_tests" \
    --asset-type "repo" \
    --asset-key "app-repo"
    
exit $exit_code
