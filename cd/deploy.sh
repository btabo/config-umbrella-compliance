#!/usr/bin/env bash
source scripts/umbrella/helpers.sh

# config
export ENVIRONMENT=$(get_env ENVIRONMENT "$(get_env cluster-region)")
export INVENTORY_URL=https://github.ibm.com/org-ids/inventory-umbrella-compliance
export DOI_TOOLCHAIN_ID=$(get_env doi-toolchain-id)
export IDS_JOB_ID=$PIPELINE_RUN_ID
export IDS_USER=idsorg
export REGISTRY_TOKEN_ID="10d3bc02-1aa0-5f94-a42a-92208f626af9"
export OTC_REGISTRY=registry.ng.bluemix.net
export PRUNE_CHART_REPO="true"
export NAMESPACE=opentoolchain
export WAIT_FOR_DEPLOY="true"
export WAIT_FOR_DEPLOY_MAX="80"
export EXCLUDED_FROM_STATUS_CHECK=$(get_env EXCLUDED_FROM_STATUS_CHECK "")
export DRY_RUN=$(get_env DRY_RUN "")
export DEPLOYMENT_SLACK_CHANNEL_ID=$(get_env DEPLOYMENT_SLACK_CHANNEL_ID "none")
case $ENVIRONMENT in
    dev)
        export INVENTORY_BRANCH="dev"
        export CHART_REPO="devops-dev"
        export CHART_BRANCH="umbrella"
        export DOMAIN="us-south.devops.dev.cloud.ibm.com"
        export FIRST_CLUSTER="otc-us-south-dev"
        export PAUSE_AFTER_FIRST_CLUSTER="false"
        export SKIP_CLUSTER_DANCE="true"
        export PAUSE_BEFORE_CLUSTER_DANCE="false"
    ;;
    mon01)
        export INVENTORY_BRANCH="mon01"
        export CHART_REPO="devops-int"
        export CHART_BRANCH="umbrella"
        export DOMAIN="$ENVIRONMENT.devops.cloud.ibm.com"
        export FIRST_CLUSTER="otc-dal10-stage"
        export PAUSE_AFTER_FIRST_CLUSTER="false"
        export SKIP_CLUSTER_DANCE="true"
        export PAUSE_BEFORE_CLUSTER_DANCE="false"
    ;;
    *)
        export INVENTORY_BRANCH=$(get_env target-environment)
        export CHART_REPO="devops-prod"
        export CHART_BRANCH="umbrella-$ENVIRONMENT"
        export DOMAIN="$ENVIRONMENT.devops.cloud.ibm.com"
        export FIRST_CLUSTER=$(get_env cluster)
        export PAUSE_AFTER_FIRST_CLUSTER=$(get_env PAUSE_AFTER_FIRST_CLUSTER "")
        export SKIP_CLUSTER_DANCE=$(get_env SKIP_CLUSTER_DANCE "")
        export PAUSE_BEFORE_CLUSTER_DANCE=$(get_env PAUSE_BEFORE_CLUSTER_DANCE "")
        export EXTRA_CLUSTER_GROUP=$(get_env EXTRA_CLUSTER_GROUP "")
    ;;
esac

# secrets
export IDS_TOKEN=$(get_env git-token)
export IC_1308775_API_KEY=$(get_env IC_1308775_API_KEY "")
export IC_1651315_API_KEY=$(get_env IC_1651315_API_KEY "$(get_env otc_IC_1651315_API_KEY "")")
export IC_1416501_API_KEY=$(get_env IC_1416501_API_KEY "$(get_env otc_IC_1416501_API_KEY "")")
export IC_1561947_API_KEY=$(get_env IC_1561947_API_KEY "")
export IC_1562047_API_KEY=$(get_env IC_1562047_API_KEY "")
export IC_2113612_API_KEY=$(get_env IC_2113612_API_KEY "")
export IC_2277151_API_KEY=$(get_env IC_2277151_API_KEY "")
export NR_1783376_API_KEY=$(get_env NR_1783376_API_KEY "")
export OTC_REGISTRY_API_KEY=$(get_env IC_1416501_API_KEY "")
export DEPLOYMENT_SLACK_TOKEN=$(get_env DEPLOYMENT_SLACK_TOKEN "none")
export ARTIFACTORY_API_KEY=$(get_env ARTIFACTORY_API_KEY)
export ROLE_ID=$(get_env ROLE_ID "")
export SECRET_ID=$(get_env SECRET_ID "")

# build umbrella chart from inventory
buildFromInventory $INVENTORY_URL $INVENTORY_BRANCH $ENVIRONMENT $ARTIFACTORY_API_KEY

function loginAndDeploy() {
    local result=$1
    local group=$2

    echo "Deploying umbrella to $group clusters"
    echo

    # login
    clusterLogin "$FIRST_CLUSTER" "$group"

    # check helm version
    source scripts/helpers/checkHelmVersion.sh

    # deploy
    deployUmbrella $ENVIRONMENT $DEPLOYMENT_SLACK_CHANNEL_ID $DEPLOYMENT_SLACK_TOKEN $SKIP_CLUSTER_DANCE $PAUSE_AFTER_FIRST_CLUSTER $PAUSE_BEFORE_CLUSTER_DANCE $group
    rc=$?
    case $rc in
        1)
            message="failed as ${ENVIRONMENT} is unknown for ${group} clusters."
        ;;
        2)
            message="failed due to cluster health check failure."
        ;;
        3)
            message="aborted by deployment coordinator."
        ;;
        *)
            unset message
        ;;
    esac

    echo "Done deploying umbrella to $group clusters"
    echo

    eval "$result=$message"
}

loginAndDeploy message "otc"

if [ -z "$message" ] && [ "$EXTRA_CLUSTER_GROUP" ]; then
    loginAndDeploy message "$EXTRA_CLUSTER_GROUP"
fi

if [ "$message" ]; then
    if [ "$DEPLOYMENT_SLACK_CHANNEL_ID" != "none" ]; then
        echo "Posting slack message: Umbrella deployment to ${ENVIRONMENT} $message"
        postSlackMessage unused "<$PIPELINE_RUN_URL|Umbrella deployment> to *${ENVIRONMENT}* $message" $DEPLOYMENT_SLACK_CHANNEL_ID $DEPLOYMENT_SLACK_TOKEN
        echo "Done"
    else
        echo "Umbrella deployment to ${ENVIRONMENT} $message"
    fi
    echo
    exit 1
fi
