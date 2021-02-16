#!/usr/bin/env bash
CONFIG_FOLDER=${1:-"/config"}

chmod u+x otc-deploy/k8s/scripts/ci/publishHelmChart.sh
./otc-deploy/k8s/scripts/ci/publishHelmChart.sh

CHART_VERSION=$(yq r -j "k8s/$APP_NAME/Chart.yaml" | jq -r '.version')
ARTIFACT="https://github.ibm.com/$CHART_ORG/$CHART_REPO/blob/master/charts/$APP_NAME-$CHART_VERSION.tgz"
echo "ARTIFACT=$ARTIFACT"

set -x

IMAGE_ARTIFACT="$(cat $CONFIG_FOLDER/artifact)"
SIGNATURE="$(cat $CONFIG_FOLDER/signature)"
APP_ARTIFACTS='{ "signature": "'${SIGNATURE}'", "provenance": "'${IMAGE_ARTIFACT}'" }'

echo which cocoa
which cocoa
echo

#
# add to inventory
#
cocoa inventory add \
    --artifact="${ARTIFACT}" \
    --repository-url="${APP_REPO}" \
    --commit-sha="${COMMIT_SHA}" \
    --build-number="${BUILD_NUMBER}" \
    --pipeline-run-id="${PIPELINE_RUN_ID}" \
    --version="$(cat $CONFIG_FOLDER/version)" \
    --name="${APP_NAME}"

cocoa inventory add \
    --artifact="${IMAGE_ARTIFACT}" \
    --repository-url="${APP_REPO}" \
    --commit-sha="${COMMIT_SHA}" \
    --build-number="${BUILD_NUMBER}" \
    --pipeline-run-id="${PIPELINE_RUN_ID}" \
    --version="$(cat $CONFIG_FOLDER/version)" \
    --name="${APP_NAME}_image" \
    --app-artifacts="${APP_ARTIFACTS}"
