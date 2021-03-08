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
export test_tiam_secret=$(get_env otc_test_tiam_secret)

# config
if [ "$(get_env app-branch)" == "integration" ]; then
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

# .pipeline_build_id
echo ".pipeline_build_id=$(<.pipeline_build_id)"

# run tests
if [ -f "$COMMON_FOLDER/../$APP_NAME/acceptance_test.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/acceptance_test.sh
else
  .jobs/test
fi
