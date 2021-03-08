#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export APP_NAME=$(get_env app-name)
cd $APP_NAME

# secrets
export CLOUDANT_IAM_API_KEY=$(get_env otc_CLOUDANT_IAM_API_KEY)
export test_tiam_secret=$(get_env otc_test_tiam_secret)

# config
export CLOUDANT_URL=$(get_env otc_CLOUDANT_URL)
export DOMAIN=stage1.ng.bluemix.net
export PORT='4000'
export url=http://localhost:4000
export TIAM_URL=https://nock-devops-api.stage1.ng.bluemix.net:443/v1/identity
export APP_MEMORY=128M
export services__otc_api=http://nock-localhost:3400/api/v1
export services__otc_ui=http://nock-localhost:3100/devops
export test_tiam_id=test

# unused?
export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_TOKEN_BASE64="$(get_env ARTIFACTORY_TOKEN_BASE64)"

# secrets and config specific to the component
if [ -f "$COMMON_FOLDER/../$APP_NAME/test_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/test_config.sh
fi

# run tests
if [ "$TESTS_SCRIPT_FILE" ]; then
    chmod u+x $TESTS_SCRIPT_FILE
    if ! $TESTS_SCRIPT_FILE; then
        exit 1
    fi
else
    echo "Skipping tests since TESTS_SCRIPT_FILE is not set"
fi