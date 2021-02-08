#!/usr/bin/env bash
CONFIG_FOLDER=${1:-"/config"}

#
# prepare data
#
echo "WORKSPACE=$WORKSPACE"

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
