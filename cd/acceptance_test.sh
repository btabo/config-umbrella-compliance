#!/usr/bin/env bash
export ENVIRONMENT=$(get_env ENVIRONMENT "get_env cluster-region")
case $ENVIRONMENT in
    dev)
        export TEST_TOOLCHAIN_ID="d5c0676c-55ed-4c25-b763-60b7afd64c87"
        export TEST_PIPELINE_ID="000d42c0-a9f7-4d7d-86f8-01160f04d1fb"
        export TEST_PIPELINE_REGION="us-south"
    ;;
    old-staging) # old staging
        export TEST_TOOLCHAIN_ID="d5c0676c-55ed-4c25-b763-60b7afd64c87"
        export TEST_PIPELINE_ID="0a86e449-cd54-4ccf-9704-28eb39c02a13"
        export TEST_PIPELINE_REGION="us-south"
    ;;
    mon01) # new staging
        export TEST_TOOLCHAIN_ID="d5c0676c-55ed-4c25-b763-60b7afd64c87"
        export TEST_PIPELINE_ID="000d42c0-a9f7-4d7d-86f8-01160f04d1fb"
        export TEST_PIPELINE_REGION="us-south"
    ;;
    eu-de)
        export TEST_TOOLCHAIN_ID="62f17f5e-b4a9-44c4-b485-e0d6f3efc28c"
        export TEST_PIPELINE_ID="e4f451b3-f832-4f48-b4d8-c7b086d447f0"
        export TEST_PIPELINE_REGION="eu-de"
    ;;
    eu-fr2)
        export TEST_TOOLCHAIN_ID="62f17f5e-b4a9-44c4-b485-e0d6f3efc28c"
        export TEST_PIPELINE_ID="ddb619d5-79a5-4de0-a4b0-e736d7253292"
        export TEST_PIPELINE_REGION="eu-de"
    ;;
    *)
        export TEST_TOOLCHAIN_ID="d5c0676c-55ed-4c25-b763-60b7afd64c87"
        export TEST_PIPELINE_ID="4ed59ae8-3e48-4c5f-9ba8-66ebd4331a60"
        export TEST_PIPELINE_REGION="us-south"
    ;;
esac
export IC_1651315_API_KEY=$(get_env IC_1651315_API_KEY "$(get_env otc_IC_1651315_API_KEY "")")
export IC_1561947_API_KEY=$(get_env IC_1561947_API_KEY "$(get_env otc_IC_1561947_API_KEY "")")
export DEPLOYMENT_SLACK_CHANNEL_ID=$(get_env DEPLOYMENT_SLACK_CHANNEL_ID "none")
export DEPLOYMENT_SLACK_TOKEN=$(get_env DEPLOYMENT_SLACK_TOKEN "none")
. /umbrella/helpers.sh
runRegionTests status "$ENVIRONMENT" "$PIPELINE_RUN_ID" "$TEST_TOOLCHAIN_ID" "$TEST_PIPELINE_ID" "$TEST_PIPELINE_REGION" $DEPLOYMENT_SLACK_CHANNEL_ID $DEPLOYMENT_SLACK_TOKEN
echo "Status of $ENVIRONMENT tests is $status"
echo

# post deployment complete message
if [ "$status" == "succeeded" ]; then
    message="complete."
else
    message="failed due to tests failure."
fi
if [ "$DEPLOYMENT_SLACK_CHANNEL_ID" != "none" ]; then
    echo "Posting slack message: Umbrella deployment to $ENVIRONMENT $message"
    postSlackMessage unused "<$PIPELINE_RUN_URL|Umbrella deployment> to *${ENVIRONMENT}* $message" $DEPLOYMENT_SLACK_CHANNEL_ID $DEPLOYMENT_SLACK_TOKEN
    echo "Done"
    echo
else
    echo "Umbrella deployment to ${ENVIRONMENT} $message"
    echo
fi

if [ "$status" != "succeeded" ]; then
    exit 1
fi
