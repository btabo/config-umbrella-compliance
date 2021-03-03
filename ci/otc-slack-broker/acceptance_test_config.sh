#!/usr/bin/env bash

CONFIG_FOLDER=$1

# secrets
export SEC_CLOUDANT_IAM_API_KEY=$(cat $CONFIG_FOLDER/otc_CLOUDANT_IAM_API_KEY)
export SEC_OTC_API_BROKER_SECRET=$(cat $CONFIG_FOLDER/otc-slack-broker_OTC_API_SECRET)
export slack_token=$(cat $CONFIG_FOLDER/otc-slack-broker_slack_token)
export test_tiam_secret=$(cat $CONFIG_FOLDER/otc_test_tiam_secret)

#config
export ENV_CLOUDANT_URL=$(cat $CONFIG_FOLDER/otc_CLOUDANT_URL)
export ENV_icons__pipeline=https://cloud.ibm.com/devops/pipelines/graphics/pipeline.png
export ENV_icons__toolchain=https://cloud.ibm.com/devops/graphics/toolchains.svg
export ENV_LOG4J_LEVEL=DEBUG
export ENV_services__otc_api=https://otc-api.us-south.devops.dev.cloud.ibm.com/
export ENV_services__otc_ui=https://dev-console.stage1.ng.bluemix.net/devops
export ENV_services__otc_ui_env_id='ibm:ys1:us-south'
export ENV_TIAM_URL=https://tiam.us-south.devops.dev.cloud.ibm.com/identity/v1
export slack_domain=https://idstest.slack.com
export test_tiam_id=test
export ENV_PORT="8080"
