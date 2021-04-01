#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE/$REPO_FOLDER

export APP_NAME=$(get_env app-name)

# secrets
export SEC_CLOUDANT_IAM_API_KEY=$(get_env otc_CLOUDANT_IAM_API_KEY)

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
export DOMAIN="otc-dal12-test.us-south.containers.mybluemix.net"
export GLOBAL_ENV_SECGRP="GRP3DEVS"
export PIPELINE_KUBERNETES_CLUSTER_NAME="otc-dal12-test"
export ENV_CLOUDANT_URL="https://b3a94817-edbc-4fc2-8c47-33d3752bc6a0-bluemix.cloudantnosqldb.appdomain.cloud/"
export ENV_LOG4J_LEVEL="DEBUG"
export ENV_services__otc_api="https://otc-api.us-south.devops.dev.cloud.ibm.com/api/v1"
export ENV_services__otc_ui="https://otc-ui.us-south.devops.dev.cloud.ibm.com/devops"
export ENV_services__otc_ui_env_id='ibm:ys1:us-south'
export ENV_TIAM_URL="https://tiam.us-south.devops.dev.cloud.ibm.com/identity/v1"
export ENV_PORT="8080"
export ENV_url="https://$APP_NAME-$NAMESPACE.$DOMAIN"

# secrets and config specific to the component
if [ -f "$COMMON_FOLDER/../$APP_NAME/deploy_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/deploy_config.sh
fi

# clone otc-deploy and devops-config if needed
GIT_TOKEN=$(cat "$WORKSPACE/git-token")
if [ ! -d "otc-deploy" ]; then
  git clone "https://$GIT_TOKEN@github.ibm.com/org-ids/otc-deploy"
fi 
if [ ! -d "devops-config" ]; then
  git clone "https://$GIT_TOKEN@github.ibm.com/ids-env/devops-config"
fi 

# login and check helm version
export IC_1308775_API_KEY=$(get_env otc_IC_1308775_API_KEY)
. otc-deploy/k8s/scripts/login/clusterLogin.sh "otc-dal12-test" "otc"
. otc-deploy/k8s/scripts/helpers/checkHelmVersion.sh

# deploy to test cluster
. otc-deploy/k8s/scripts/deployComponentToCluster.sh
