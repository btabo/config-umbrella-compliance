#!/usr/bin/env bash

CONFIG_FOLDER=$1

export ENV_CLOUDANT_URL="topasshelmlintstrict"
export SEC_CLOUDANT_IAM_API_KEY="topasshelmlintstrict"
export SEC_OTC_API_BROKER_SECRET="topasshelmlintstrict"
export ENV_services__otc_ui="topasshelmlintstrict"
export ENV_services__otc_ui_env_id="topasshelmlintstrict"
export ENV_PORT="8080"
export PIPELINE_KUBERNETES_CLUSTER_NAME="otc-dal12-test"