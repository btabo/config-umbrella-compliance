#!/usr/bin/env bash
COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FOLDER=${1:-"/config"}

GIT_TOKEN=$(cat "$WORKSPACE/git-token")
if [ ! -d "otc-deploy" ]; then
  git clone "https://$GIT_TOKEN@github.ibm.com/org-ids/otc-deploy"
fi 
APP_NAME=$(cat $CONFIG_FOLDER/app-name)
if [ -f "$COMMON_FOLDER/../$APP_NAME/release_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/release_config.sh $CONFIG_FOLDER
fi

BRANCH=$(cat $CONFIG_FOLDER/revision)
if [ "$BRANCH" == "master" ]; then
    export DOMAIN="devops.dev.us-south.bluemix.net"
    export NUM_INSTANCES="1"
    export CHART_REPO="devops-dev"
    export PRUNE_CHART_REPO="true"
else
    export DOMAIN="stage.us-south.devops.cloud.ibm.com"
    export NUM_INSTANCES="3"
    export CHART_REPO="devops-int"
    export PRUNE_CHART_REPO="false"
fi
export NAMESPACE="opentoolchain"
export RELEASE_NAME="$APP_NAME"
export MAJOR_VERSION="1"
export MINOR_VERSION="0"
export CHART_ORG="ids-env"
#export TRIGGER_BRANCH="trigger-deploy"
export LOGICAL_APP_NAME="$APP_NAME"
export BUILD_PREFIX="$BRANCH"