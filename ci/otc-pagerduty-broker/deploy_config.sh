#!/usr/bin/env bash

CONFIG_FOLDER=$1

# secrets
export SEC_OTC_API_BROKER_SECRET=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_OTC_API_SECRET)
export pagerduty_api_key=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_api_key)
export pagerduty_api_key_2=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_api_key_2)
export test_tiam_secret=$(cat $CONFIG_FOLDER/otc_test_tiam_secret)
export SEC_ENCRYPTION_KEY=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_ENCRYPTION_KEY)
export SEC_CLOUDANT_IAM_API_KEY=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_CLOUDANT_IAM_API_KEY)
 
# config 
if [ "$(cat $CONFIG_FOLDER/app-branch)" == "integration" ]; then
    export NAMESPACE="otc-int"
    export RELEASE_NAME=$APP_NAME-$NAMESPACE
else
    export NAMESPACE="opentoolchain"
    export RELEASE_NAME=$APP_NAME
fi
export ENV_CLOUDANT_URL=$(cat $CONFIG_FOLDER/otc_CLOUDANT_URL)
export ENV_LOG4J_LEVEL="DEBUG"
export ENV_services__otc_api="https://otc-api.us-south.devops.dev.cloud.ibm.com/api/v1"
export ENV_services__otc_ui="https://otc-ui.us-south.devops.dev.cloud.ibm.com/devops"
export ENV_services__otc_ui_env_id='ibm:ys1:us-south'
export ENV_TIAM_URL="https://tiam.us-south.devops.dev.cloud.ibm.com/identity/v1"
export pagerduty_site_name="ibmdevops"
export pagerduty_site_name_2="ibmdevops"
export test_tiam_id="test"
export ENV_PORT="8080"
export NUM_INSTANCES='1'
export COMPONENT_NAME=$APP_NAME
export IMAGE_TAG="latest" #unused ?
export ROUTE=$APP_NAME-$NAMESPACE
export DOMAIN="otc-dal12-test.us-south.containers.mybluemix.net"
export GLOBAL_ENV_SECGRP="GRP3DEVS"
export ENV_url="https://$APP_NAME-$NAMESPACE.$DOMAIN"
export PIPELINE_KUBERNETES_CLUSTER_NAME="otc-dal12-test"