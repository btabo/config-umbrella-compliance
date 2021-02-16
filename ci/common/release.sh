#!/usr/bin/env bash
CONFIG_FOLDER=${1:-"/config"}

# build and publish component chart to solution repo
chmod u+x otc-deploy/k8s/scripts/ci/publishHelmChart.sh
./otc-deploy/k8s/scripts/ci/publishHelmChart.sh

# add to inventory
CHART_VERSION=$(yq r -j "k8s/$APP_NAME/Chart.yaml" | jq -r '.version')
ARTIFACT="https://github.ibm.com/$CHART_ORG/$CHART_REPO/blob/master/charts/$APP_NAME-$CHART_VERSION.tgz"
IMAGE_ARTIFACT="$(cat $CONFIG_FOLDER/artifact)"
if [ -f $CONFIG_FOLDER/signature ]; then
    # using TaaS worker
    SIGNATURE="$(cat $CONFIG_FOLDER/signature)"
    APP_ARTIFACTS='{ "signature": "'${SIGNATURE}'", "provenance": "'${IMAGE_ARTIFACT}'" }'
else
    # using regular worker, no signature
    APP_ARTIFACTS='{ "provenance": "'${IMAGE_ARTIFACT}'" }'
fi
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
