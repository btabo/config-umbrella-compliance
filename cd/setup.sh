#!/usr/bin/env bash

# post deployment started message
export ENVIRONMENT=$(get_env ENVIRONMENT "$(get_env cluster-region)")
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