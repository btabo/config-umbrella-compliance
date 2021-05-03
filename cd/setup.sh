#!/usr/bin/env bash

# post deployment started message
export ENVIRONMENT=$(get_env ENVIRONMENT "get_env cluster-region")
export DEPLOYMENT_SLACK_CHANNEL_ID=$(get_env DEPLOYMENT_SLACK_CHANNEL_ID "none")
export DEPLOYMENT_SLACK_TOKEN=$(get_env DEPLOYMENT_SLACK_TOKEN "none")
if [ "$DEPLOYMENT_SLACK_CHANNEL_ID" != "none" ]; then
    echo "Posting slack message: Umbrella deployment to $ENVIRONMENT started."
    . /umbrella/helpers.sh
    postSlackMessage unused "<$PIPELINE_RUN_URL|Umbrella deployment> to *${ENVIRONMENT}* started." $DEPLOYMENT_SLACK_CHANNEL_ID $DEPLOYMENT_SLACK_TOKEN
    echo "Done"
else
    echo "Umbrella deployment to $ENVIRONMENT started."
fi
echo

# TEMP: manually build inventory for dev, will remove when all components have switched to shiftleft ci pipelines
if [ "$ENVIRONMENT" == "dev" ]; then
    export IDS_USER=idsorg
    export IDS_TOKEN=$(get_env git-token)
    export INVENTORY_URL=https://github.ibm.com/org-ids/inventory-umbrella-compliance
    export INVENTORY_BRANCH=dev
    mkdir temp
    cd temp
    . /umbrella/helpers.sh
    updateInventory $BUILD_NUMBER $PIPELINE_RUN_ID "0a86e449-cd54-4ccf-9704-28eb39c02a13" "crn:v1:bluemix:public:toolchain:us-south:a/779c0808c946b9e15cc2e63013fded8c:16bb7fb7-4284-479f-b57f-ec08a12eb603::" $INVENTORY_URL $INVENTORY_BRANCH
    cd ..
    rm -rf temp
fi
