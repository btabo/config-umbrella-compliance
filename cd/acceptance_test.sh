#!/usr/bin/env bash
export ENVIRONMENT=$(get_env ENVIRONMENT "$(get_env cluster-region)")
case $ENVIRONMENT in
    dev)
        export PAUSE_BEFORE_TESTS="false"
        export TEST_TOOLCHAIN_ID="d5c0676c-55ed-4c25-b763-60b7afd64c87"
        export TEST_PIPELINE_ID="000d42c0-a9f7-4d7d-86f8-01160f04d1fb"
        export TEST_PIPELINE_REGION="us-south"
    ;;
    old-staging) # old staging
        export PAUSE_BEFORE_TESTS=$(get_env PAUSE_BEFORE_TESTS "false")
        export TEST_TOOLCHAIN_ID="d5c0676c-55ed-4c25-b763-60b7afd64c87"
        export TEST_PIPELINE_ID="0a86e449-cd54-4ccf-9704-28eb39c02a13"
        export TEST_PIPELINE_REGION="us-south"
    ;;
    mon01) # new staging
        export PAUSE_BEFORE_TESTS="false"
        export TEST_TOOLCHAIN_ID="d5c0676c-55ed-4c25-b763-60b7afd64c87"
        export TEST_PIPELINE_ID="000d42c0-a9f7-4d7d-86f8-01160f04d1fb"
        export TEST_PIPELINE_REGION="us-south"
    ;;
    *)
        export PAUSE_BEFORE_TESTS=$(get_env PAUSE_BEFORE_TESTS "false")
        export TEST_TOOLCHAIN_ID="d5c0676c-55ed-4c25-b763-60b7afd64c87"
        export TEST_PIPELINE_ID="4ed59ae8-3e48-4c5f-9ba8-66ebd4331a60"
        export TEST_PIPELINE_REGION="us-south"
    ;;
esac
export DOI_TOOLCHAIN_ID=$(get_env doi-toolchain-id)
export IC_1308775_API_KEY=$(get_env IC_1308775_API_KEY "$(get_env otc_IC_1308775_API_KEY "")")
export IC_1651315_API_KEY=$(get_env IC_1651315_API_KEY "$(get_env otc_IC_1651315_API_KEY "")")
export IC_1561947_API_KEY=$(get_env IC_1561947_API_KEY "$(get_env otc_IC_1561947_API_KEY "")")
export DEPLOYMENT_SLACK_CHANNEL_ID=$(get_env DEPLOYMENT_SLACK_CHANNEL_ID "none")
export DEPLOYMENT_SLACK_TOKEN=$(get_env DEPLOYMENT_SLACK_TOKEN "none")
export IDS_TOKEN=$(get_env git-token)

. /umbrella/helpers.sh

# optionally pause before running the tests
if [ "$PAUSE_BEFORE_TESTS" == "true" ]; then
    if [ "$DEPLOYMENT_SLACK_CHANNEL_ID" != "none" ]; then
        echo "Posting about to start tests slack message"
        SLACK_MESSAGE="<$PIPELINE_RUN_URL|Umbrella deployment> to *${ENVIRONMENT}* is about to start the tests.\nDeployment coordinator shall use :gogo: to proceed, or :stop: to abort."   
        postSlackMessage MESSAGE_TIMESTAMP "$SLACK_MESSAGE" $DEPLOYMENT_SLACK_CHANNEL_ID $DEPLOYMENT_SLACK_TOKEN
        echo "Done"
        echo
        echo "Waiting for go to start tests..." 
        waitForSlackGoNoGo go $MESSAGE_TIMESTAMP $DEPLOYMENT_SLACK_CHANNEL_ID $DEPLOYMENT_SLACK_TOKEN "gogo" "stop"
        if [ "$go" == "stop" ]; then
            echo "Got a no go to start testing"
            echo
            echo "Posting slack message: Umbrella deployment to ${ENVIRONMENT} aborted by deployment coordinator."
            postSlackMessage unused "<$PIPELINE_RUN_URL|Umbrella deployment> to *${ENVIRONMENT}* aborted by deployment coordinator." $DEPLOYMENT_SLACK_CHANNEL_ID $DEPLOYMENT_SLACK_TOKEN
            echo "Done"
            exit 1
        fi
        echo "Go a go to start testing"
        echo
    else
        echo "Cannot pause before tests since no slack channel id was provided"
        echo
    fi
fi

# collect build ids of each umbrella component for publishing insights test records 
if [ "$ENVIRONMENT" != "eu-fr2" ]; then # not reachable from outside, tests are not run there
    collectUmbrellaBuildIds BUILD_IDS $ENVIRONMENT
fi

# run tests
runRegionTests status "{ \
  \"region\": \"$ENVIRONMENT\", \
  \"callerRunId\": \"$PIPELINE_RUN_ID\", \
  \"buildNumber\": \"$BUILD_NUMBER\", \
  \"testToolchainId\": \"$TEST_TOOLCHAIN_ID\", \
  \"testPipelineId\": \"$TEST_PIPELINE_ID\", \
  \"testPipelineRegion\": \"$TEST_PIPELINE_REGION\", \
  \"deploymentSlackChannelId\": \"$DEPLOYMENT_SLACK_CHANNEL_ID\", \
  \"deploymentSlackToken\": \"$DEPLOYMENT_SLACK_TOKEN\", \
  \"doiToolchainId\": \"$DOI_TOOLCHAIN_ID\", \
  \"doiAppName\": \"CD-Umbrella\", \
  \"doiBuildId\": \"umbrella-$ENVIRONMENT-$BUILD_NUMBER\", \
  \"doiBuildIds\": \"$BUILD_IDS\" \
}"
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
