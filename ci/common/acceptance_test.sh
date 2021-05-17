#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export APP_NAME=$(get_env app-name)
if [ -f $COMMON_FOLDER/../$APP_NAME/acceptance_test.sh ]; then
    source $COMMON_FOLDER/../$APP_NAME/acceptance_test.sh
    exit 0
fi

REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE/$REPO_FOLDER


# secrets
export test_tiam_secret=$(get_env otc_test_tiam_secret)
export ARTIFACTORY_AUTH_BASE64="$(get_env otc_ARTIFACTORY_AUTH_BASE64 "")"

# config
if [ "$(load_repo app-repo branch)" == "integration" ]; then
    export NAMESPACE="otc-int"
    export RELEASE_NAME=$APP_NAME-$NAMESPACE
else
    export NAMESPACE="opentoolchain"
    export RELEASE_NAME=$APP_NAME
fi
export TIAM_URL="https://tiam.us-south.devops.dev.cloud.ibm.com/identity/v1"
export DOMAIN="otc-dal12-test.us-south.containers.mybluemix.net"
export _DEPLOY_url="https://$APP_NAME-$NAMESPACE.$DOMAIN"

# Define the TEST_URL but let's the script 'acceptance_test_config.sh' being able to refine it
export TEST_URL="https://$APP_NAME-$NAMESPACE.$DOMAIN/status"

# secrets and config specific to the component
if [ -f "$COMMON_FOLDER/../$APP_NAME/acceptance_test_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/acceptance_test_config.sh
fi

# healthchek of the new deployed service instance
if [ "$SKIP_HEALTH_CHECK" == "true" ]; then
    echo "Skipping healthcheck on the component status endpoint"
else
    http_code_test_url=$(curl -s -k -o /dev/null -w "%{http_code}" "${TEST_URL}")
    timeout=300 # time out after 5 min
    end=$((SECONDS+$timeout))
    while [ $SECONDS -lt $end ]; do 
        case $http_code_test_url in
            200)
                echo "${TEST_URL} is successful"
                break
                ;;
            500|501|502)
                # 50? errors can occur during the interval while the POD is in creation
                echo "Got a $http_code_test_url on $TEST_URL"
                echo "Assuming the app is starting and retrying in 30s ..."
                sleep 30
                http_code_test_url=$(curl -s -k -o /dev/null -w "%{http_code}" "${TEST_URL}")
                ;;
            *)
                echo "${TEST_URL} can not be reached (http_code: ${http_code_test_url})"
                exit 1
                ;;
        esac
    done
     if [ $SECONDS -ge $end ]; then
        echo "Timing out after $timeout seconds"
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