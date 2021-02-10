#!/usr/bin/env bash

CONFIG_FOLDER=$1

export NAMESPACE="opentoolchain"
export NUM_INSTANCES='1'
export RELEASE_NAME=$(cat $CONFIG_FOLDER/app-name)
export COMPONENT_NAME=$(cat $CONFIG_FOLDER/app-name)
export IMAGE_TAG= "latest"
export ROUTE=$(cat $CONFIG_FOLDER/app-name)
export DOMAIN="otc-dal12-test.us-south.containers.mybluemix.net"
export GLOBAL_ENV_SECGRP="GRP3DEVS"
export ENV_url="https://$COMPONENT_NAME.$DOMAIN"
export PIPELINE_KUBERNETES_CLUSTER_NAME="otc-dal12-test"

export CLOUDANT_URL=$(cat $CONFIG_FOLDER/pagerduty_CLOUDANT_URL)
export LOG4J_LEVEL='DEBUG'
export PORT='8080'
export TIAM_URL='https://tiam.us-south.devops.dev.cloud.ibm.com/identity/v1'
export services__otc_api='https://otc-api.us-south.devops.dev.cloud.ibm.com/api/v1'
export services__otc_ui='https://otc-ui.us-south.devops.dev.cloud.ibm.com/devops'
export services__otc_ui_env_id='ibm:ys1:us-south'