#!/usr/bin/env bash
CONFIG_FOLDER=${1:-"/config"}

# build and publish component chart

echo "Workaround to find a suitable BUILD_NUMBER for helm chart revision
number"

git clone --depth 1 https://$IDS_USER:$IDS_TOKEN@github.ibm.com/ids-env/$CHART_REPO || true

NEXT_VERSION=$(ls -v ${CHART_REPO}/charts/${LOGICAL_APP_NAME}* 2> /dev/null | tail -n -1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | awk -F'.' -v OFS='.' '{$3=sprintf("%d",++$3)}7')

if [ -z "$NEXT_VERSION" ]; then
    NEXT_VERSION="$MAJOR_VERSION.$MINOR_VERSION.0"
fi

export BUILD_NUMBER=$(echo "$NEXT_VERSION" | awk -F. '{print $3}')

rm -r -f $CHART_REPO

echo "Next helm chart version will be $NEXT_VERSION"

echo "Compute BUILD_NUMBER to $BUILD_NUMBER"

#export IMAGE_TAG=$LATEST_IMAGE_TAG

export ENV_BUILD_TIMESTAMP=$(date +%s%3N)

# Build and Package the Helm Chart for dev environment

chmod u+x otc-deploy/k8s/scripts/ci/publishHelmChart.sh
./otc-deploy/k8s/scripts/ci/publishHelmChart.sh

#
# prepare data
#
export GHE_TOKEN=$(cat "$WORKSPACE/git-token")
export COMMIT_SHA="$(cat $CONFIG_FOLDER/git-commit)"
export APP_NAME="$(cat $CONFIG_FOLDER/app-name)"

INVENTORY_REPO="$(cat $CONFIG_FOLDER/inventory-url)"
GHE_ORG=${INVENTORY_REPO%/*}
export GHE_ORG=${GHE_ORG##*/}
GHE_REPO=${INVENTORY_REPO##*/}
export GHE_REPO=${GHE_REPO%.git}

export APP_REPO="$(cat $CONFIG_FOLDER/repository-url)"
APP_REPO_ORG=${APP_REPO%/*}
export APP_REPO_ORG=${APP_REPO_ORG##*/}
APP_REPO_NAME=${APP_REPO##*/}
export APP_REPO_NAME=${APP_REPO_NAME%.git}

# TODO: build compponent chart here
ARTIFACT="https://github.ibm.com/ids-env/devops-int/blob/master/charts/otc-pagerduty-broker-1.0.77.tgz"

IMAGE_ARTIFACT="$(cat $CONFIG_FOLDER/artifact)"
SIGNATURE="$(cat $CONFIG_FOLDER/signature)"
APP_ARTIFACTS='{ "signature": "'${SIGNATURE}'", "provenance": "'${IMAGE_ARTIFACT}'" }'
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
