#!/usr/bin/env bash
COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FOLDER=${1:-"/config"}

# clone otc-deploy and devops-config if needed
GIT_TOKEN=$(cat "$WORKSPACE/git-token")
if [ ! -d "otc-deploy" ]; then
  git clone "https://$GIT_TOKEN@github.ibm.com/org-ids/otc-deploy"
fi 
if [ ! -d "devops-config" ]; then
  git clone "https://$GIT_TOKEN@github.ibm.com/ids-env/devops-config"
fi 

# secrets and config
export APP_NAME=$(cat $CONFIG_FOLDER/app-name)
if [ -f "$COMMON_FOLDER/../$APP_NAME/release_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/release_config.sh $CONFIG_FOLDER
fi

# to pass helm lint --strict
export SEC_CLOUDANT_IAM_API_KEY="topasshelmlintstrict"
export SEC_OTC_API_BROKER_SECRET="topasshelmlintstrict"
export ENV_CLOUDANT_URL="topasshelmlintstrict"
export ENV_services__otc_ui="topasshelmlintstrict"
export ENV_services__otc_ui_env_id="topasshelmlintstrict"
export ENV_url="topasshelmlintanddryrun"
export ENV_TIAM_URL="topasshelmlintanddryrun"
export ENV_PORT="8080"
export GLOBAL_ENV_SECGRP="topasshelmlintanddryrun"
export PIPELINE_KUBERNETES_CLUSTER_NAME="otc-dal12-test"

# for building helm chart
export IDS_USER="idsorg"
export IDS_TOKEN=$GIT_TOKEN
export BRANCH=$(cat $CONFIG_FOLDER/app-branch)
if [ "$BRANCH" == "integration" ]; then
    export DOMAIN="stage.us-south.devops.cloud.ibm.com"
    export NUM_INSTANCES="3"
    export CHART_REPO="devops-int"
    export PRUNE_CHART_REPO="false"
else
    export DOMAIN="devops.dev.us-south.bluemix.net"
    export NUM_INSTANCES="1"
    export CHART_REPO="devops-dev"
    export PRUNE_CHART_REPO="true"
fi
export NAMESPACE="opentoolchain"
export RELEASE_NAME="$APP_NAME"
export MAJOR_VERSION="1"
export MINOR_VERSION="0"
export CHART_ORG="jerome-lanneluc" #"ids-env"
#export TRIGGER_BRANCH="trigger-deploy"
export LOGICAL_APP_NAME="$APP_NAME"
export BUILD_PREFIX="$BRANCH"
export ENV_BUILD_TIMESTAMP=$(date +%s%3N)
export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_TOKEN_BASE64="$(cat $CONFIG_FOLDER/ARTIFACTORY_TOKEN_BASE64)"

export IC_1308775_API_KEY=$(cat $CONFIG_FOLDER/IC_1308775_API_KEY)
. otc-deploy/k8s/scripts/login/clusterLogin.sh "otc-dal12-test" "otc"
. otc-deploy/k8s/scripts/helpers/checkHelmVersion.sh

# compute BUILD_NUMBER
echo "Workaround to find a suitable BUILD_NUMBER for helm chart revision number"
git clone --depth 1 https://$IDS_USER:$IDS_TOKEN@github.ibm.com/ids-env/$CHART_REPO || true
NEXT_VERSION=$(ls -v ${CHART_REPO}/charts/${LOGICAL_APP_NAME}* 2> /dev/null | tail -n -1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | awk -F'.' -v OFS='.' '{$3=sprintf("%d",++$3)}7')
if [ -z "$NEXT_VERSION" ]; then
    NEXT_VERSION="$MAJOR_VERSION.$MINOR_VERSION.0"
fi
export BUILD_NUMBER=$(echo "$NEXT_VERSION" | awk -F. '{print $3}')
rm -r -f $CHART_REPO
echo "Next helm chart version will be $NEXT_VERSION"
echo "Compute BUILD_NUMBER to $BUILD_NUMBER"

# install cocoa cli
COCOA_CLI_VERSION=1.5.0
ARTIFACTORY_API_KEY=$(base64 -d <<< $ARTIFACTORY_TOKEN_BASE64)
curl -u ${ARTIFACTORY_ID}:${ARTIFACTORY_API_KEY} -O "https://eu.artifactory.swg-devops.com/artifactory/wcp-compliance-automation-team-generic-local/cocoa-linux-${COCOA_CLI_VERSION}"
cp cocoa-linux-* /usr/local/bin/cocoa
chmod +x /usr/local/bin/cocoa
export PATH="$PATH:/usr/local/bin/"

# for cocoa cli
export GHE_TOKEN="$(cat $WORKSPACE/git-token)"
export COMMIT_SHA="$(cat $CONFIG_FOLDER/git-commit)"
if [ "$BRANCH" == "integration" ]; then
  export INVENTORY_BRANCH="staging"
else
  export INVENTORY_BRANCH="dev"
fi
INVENTORY_REPO=$(cat $CONFIG_FOLDER/inventory-url)
GHE_ORG=${INVENTORY_REPO%/*}
export GHE_ORG=${GHE_ORG##*/}
GHE_REPO=${INVENTORY_REPO##*/}
export GHE_REPO=${GHE_REPO%.git}
APP_REPO=$(cat $CONFIG_FOLDER/repository-url)
APP_REPO_ORG=${APP_REPO%/*}
export APP_REPO_ORG=${APP_REPO_ORG##*/}
APP_REPO_NAME=${APP_REPO##*/}
export APP_REPO_NAME=${APP_REPO_NAME%.git}