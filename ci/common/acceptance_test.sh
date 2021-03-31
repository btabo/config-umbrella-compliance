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

# secrets
export test_tiam_secret=$(get_env otc_test_tiam_secret)
export ARTIFACTORY_AUTH_BASE64="$(get_env otc_ARTIFACTORY_AUTH_BASE64 "")"

# config
if [ "$(get_env branch)" == "integration" ]; then
    export NAMESPACE="otc-int"
    export RELEASE_NAME=$APP_NAME-$NAMESPACE
else
    export NAMESPACE="opentoolchain"
    export RELEASE_NAME=$APP_NAME
fi
export TIAM_URL="https://tiam.us-south.devops.dev.cloud.ibm.com/identity/v1"
export DOMAIN="otc-dal12-test.us-south.containers.mybluemix.net"
export _DEPLOY_url="https://$APP_NAME-$NAMESPACE.$DOMAIN"

# secrets and config specific to the component
if [ -f "$COMMON_FOLDER/../$APP_NAME/acceptance_test_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/acceptance_test_config.sh
fi

# healthchek of the new deployed service instance
if [ "$SKIP_HEALTH_CHECK" == "true" ]; then
    echo "Skipping healthcheck on the component status endpoint"
else
    TEST_URL="https://$APP_NAME-$NAMESPACE.$DOMAIN/status"
    echo "TEST_URL=$TEST_URL"
    # 502 is Bad Gateway that can occurs during the interval while the POD is in creation
    while [ $(curl -s -k -o /dev/null -w "%{http_code}" "$TEST_URL") == 502 ]; do
        echo -n '.'
        sleep 10
    done
    while [ $(curl -s -k -o /dev/null -w "%{http_code}" "$TEST_URL") == 501 ]; do
        echo -n '.'
        sleep 10
    done

    http_code_test_url=$(curl -s -k -o /dev/null -w "%{http_code}" "${TEST_URL}")
    if [ "$http_code_test_url" == "200" ]; then
        echo "${TEST_URL} is successful"
    else
        echo "${TEST_URL} can not be reached (http_code: ${http_code_test_url}) - deployment failed."
        exit 1
    fi
    echo
fi

# run tests
if [ "$ACCEPTANCE_TESTS_SCRIPT_FILE" ]; then
    chmod u+x $ACCEPTANCE_TESTS_SCRIPT_FILE
    if ! $ACCEPTANCE_TESTS_SCRIPT_FILE; then
        echo "Acceptance tests failed"
        exit 1
    fi
else
    echo "Skipping tests since ACCEPTANCE_TESTS_SCRIPT_FILE is not set"
fi