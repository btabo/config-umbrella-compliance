#!/usr/bin/env bash
source ./ci/common/helpers.sh

# debug
echo "kubectl version"
kubectl version
echo
echo "oc version"
oc version
echo

# get otc-deploy scripts
echo "Getting otc-deploy scripts..."
echo
cloneOtcDeploy
mkdir scripts
mv otc-deploy/k8s/scripts/* scripts
mv devops-config/otc-deploy/* scripts/otc-config
cleanupOtcDeploy
echo "ls -l scripts"
ls -l scripts
echo "Done getting otc-deploy scripts"
echo

# post deployment started message
export ENVIRONMENT=$(get_env ENVIRONMENT "$(get_env cluster-region)")
export DEPLOYMENT_SLACK_CHANNEL_ID=$(get_env DEPLOYMENT_SLACK_CHANNEL_ID "none")
export DEPLOYMENT_SLACK_TOKEN=$(get_env DEPLOYMENT_SLACK_TOKEN "none")
if [ "$DEPLOYMENT_SLACK_CHANNEL_ID" != "none" ]; then
    echo "Posting slack message: Umbrella deployment to $ENVIRONMENT started."
    . scripts/umbrella/helpers.sh
    postSlackMessage unused "<$PIPELINE_RUN_URL|Umbrella deployment> to *${ENVIRONMENT}* started." $DEPLOYMENT_SLACK_CHANNEL_ID $DEPLOYMENT_SLACK_TOKEN
    echo "Done"
else
    echo "Umbrella deployment to $ENVIRONMENT started."
fi
echo