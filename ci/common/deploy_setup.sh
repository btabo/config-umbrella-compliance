#!/usr/bin/env bash
COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FOLDER=${1:-"/config"}

GIT_TOKEN=$(cat "$WORKSPACE/git-token")
if [ ! -d "otc-deploy" ]; then
  git clone "https://$GIT_TOKEN@github.ibm.com/org-ids/otc-deploy"
fi 
if [ ! -d "devops-config" ]; then
  git clone "https://$GIT_TOKEN@github.ibm.com/ids-env/devops-config"
fi 
export APP_NAME=$(cat $CONFIG_FOLDER/app-name)
if [ -f "$COMMON_FOLDER/../$APP_NAME/deploy_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/deploy_config.sh $CONFIG_FOLDER
fi
export IC_1308775_API_KEY=$(cat $CONFIG_FOLDER/IC_1308775_API_KEY)
. otc-deploy/k8s/scripts/login/clusterLogin.sh "otc-dal12-test"
. otc-deploy/k8s/scripts/helpers/checkHelmVersion.sh