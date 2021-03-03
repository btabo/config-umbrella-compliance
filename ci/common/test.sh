#!/usr/bin/env bash

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FOLDER=${1:-"/config"}

# secrets
export CLOUDANT_IAM_API_KEY=$(cat $CONFIG_FOLDER/otc_CLOUDANT_IAM_API_KEY)
export test_tiam_secret=$(cat $CONFIG_FOLDER/otc_test_tiam_secret)

# config
export APP_NAME=$(cat $CONFIG_FOLDER/app-name)
export CLOUDANT_URL=$(cat $CONFIG_FOLDER/otc_CLOUDANT_URL)
export DOMAIN=stage1.ng.bluemix.net
export PORT='4000'
export url=http://localhost:4000
export TIAM_URL=https://nock-devops-api.stage1.ng.bluemix.net:443/v1/identity
export APP_MEMORY=128M
export services__otc_api=http://nock-localhost:3400/api/v1
export services__otc_ui=http://nock-localhost:3100/devops
export test_tiam_id=test

# secrets and config specific to components
if [ -f "$COMMON_FOLDER/../$APP_NAME/tests_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/tests_config.sh $CONFIG_FOLDER
fi

export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_TOKEN_BASE64="$(cat $CONFIG_FOLDER/ARTIFACTORY_TOKEN_BASE64)"

# temp
echo ==============================================
env | sort
echo ==============================================
echo

chmod +x .jobs/nock
.jobs/nock