#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $COMMON_FOLDER/../../helpers.sh

export APP_NAME=$(get_env app-name)
if [ -f $COMMON_FOLDER/../$APP_NAME/deploy.sh ]; then
    source $COMMON_FOLDER/../$APP_NAME/deploy.sh
    exit $?
fi

REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE/$REPO_FOLDER

# secrets
export SEC_CLOUDANT_IAM_API_KEY=$(get_env otc_CLOUDANT_IAM_API_KEY)
export SEC_TOOLCHAIN_API_KEY=$(get_env otc-integration-broker_TOOLCHAIN_API_KEY)

# config
if [ "$(load_repo app-repo branch)" == "integration" ]; then
    export NAMESPACE="otc-int"
    export RELEASE_NAME=$APP_NAME-$NAMESPACE
else
    export NAMESPACE="opentoolchain"
    export RELEASE_NAME=$APP_NAME
fi
export NUM_INSTANCES='1'
export COMPONENT_NAME=$APP_NAME
export IMAGE_TAG="latest" #unused ?
export ROUTE=$APP_NAME-$NAMESPACE
export DOMAIN="otc-dal10-test-ebc4c2329856a2fac5ef9072561d9bbf-0000.us-south.containers.appdomain.cloud"
export GLOBAL_ENV_SECGRP="GRP3DEVS"
export PIPELINE_KUBERNETES_CLUSTER_NAME="otc-dal10-test"
export ENV_CLOUDANT_URL="https://3972fdbd-33a6-4174-a595-e54fb1a52e56-bluemix.cloudant.com/"
export ENV_LOG4J_LEVEL="DEBUG"
export ENV_services__otc_api="https://otc-api.us-south.devops.dev.cloud.ibm.com/api/v1"
export ENV_services__otc_ui="https://otc-ui.us-south.devops.dev.cloud.ibm.com/devops"
export ENV_services__otc_ui_env_id='ibm:ys1:us-south'
export ENV_TIAM_URL="https://tiam.us-south.devops.dev.cloud.ibm.com/identity/v1"
export ENV_PORT="8080"
export ENV_url="https://$APP_NAME-$NAMESPACE.$DOMAIN"
# kms_info
export ENV_ENABLE_KMS="true"
export ENV_KMS_REGION="dev"
export ENV_SENTINEL_KMS_URL="https://qa.us-south.kms.test.cloud.ibm.com"
export ENV_SENTINEL_KMS_INSTANCE_ID="fd3d423f-f1c3-4af0-bf40-569c60f22376"
export ENV_SENTINEL_ROOT_KEY_ID="57e8bb2b-fa76-48f5-a323-35750fef17dc"
export ENV_SENTINEL_TOOLCHAIN_CRN="crn:v1:staging:public:toolchain:us-south:a/79df5267605f4fa8aa2db7b8dfcf2197:c14cc969-83c8-462d-89aa-c9722aef5be2::"

# secrets and config specific to the component
if [ -f "$COMMON_FOLDER/../$APP_NAME/deploy_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/deploy_config.sh
fi

# clone otc-deploy and devops-config if needed
cloneOtcDeploy

# deploy to test cluster
export IC_1651315_API_KEY=$(get_env otc_IC_1651315_API_KEY)
. otc-deploy/k8s/scripts/login/clusterLogin.sh "otc-dal10-test" "otc"
. otc-deploy/k8s/scripts/deployComponentToCluster.sh
