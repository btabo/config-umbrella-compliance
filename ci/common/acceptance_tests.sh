#!/usr/bin/env bash

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FOLDER=${1:-"/config"}

# secrets
export SEC_CLOUDANT_IAM_API_KEY=$(cat $CONFIG_FOLDER/otc_CLOUDANT_IAM_API_KEY)

# config
export APP_NAME=$(cat $CONFIG_FOLDER/app-name)
if [ "$(cat $CONFIG_FOLDER/app-branch)" == "integration" ]; then
    export NAMESPACE="otc-int"
    export RELEASE_NAME=$APP_NAME-$NAMESPACE
else
    export NAMESPACE="opentoolchain"
    export RELEASE_NAME=$APP_NAME
fi
export TIAM_URL="https://tiam.us-south.devops.dev.cloud.ibm.com/identity/v1"
export DOMAIN="otc-dal12-test.us-south.containers.mybluemix.net"
export _DEPLOY_url="https://$APP_NAME-$NAMESPACE.$DOMAIN"

# secrets and config specific to components
if [ -f "$COMMON_FOLDER/../$APP_NAME/acceptance_tests_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/acceptance_tests_config.sh $CONFIG_FOLDER
fi

# .pipeline_build_id
echo ".pipeline_build_id=$(<.pipeline_build_id)"

# run tests
.jobs/test
