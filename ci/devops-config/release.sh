#!/usr/bin/env bash
source ./ci/common/helpers.sh

# do not add to inventory if it cannot be deployed
if ! checkComplianceStatuses; then
    echo "Skipping release stage."
    exit 0
fi

cd $WORKSPACE/devops-config

# for cocoa cli
export GHE_TOKEN="$(cat $WORKSPACE/git-token)"
export COMMIT_SHA="$(get_env git-commit)"
INVENTORY_REPO=$(get_env TEMP_INVENTORY_REPO "$(get_env inventory-url)" )
GHE_ORG=${INVENTORY_REPO%/*}
export GHE_ORG=${GHE_ORG##*/}
GHE_REPO=${INVENTORY_REPO##*/}
export GHE_REPO=${GHE_REPO%.git}

cocoa inventory add \
    --environment="dev" \
    --artifact="https://github.ibm.com/ids-env/devops-config/tree/${COMMIT_SHA}/environments" \
    --repository-url="$(get_env repository)" \
    --commit-sha="${COMMIT_SHA}" \
    --build-number="${BUILD_NUMBER}" \
    --pipeline-run-id="${PIPELINE_RUN_ID}" \
    --version="$(get_env version)" \
    --name="config"

cocoa inventory add \
    --environment="staging" \
    --artifact="https://github.ibm.com/ids-env/devops-config/tree/${COMMIT_SHA}/environments" \
    --repository-url="$(get_env repository)" \
    --commit-sha="${COMMIT_SHA}" \
    --build-number="${BUILD_NUMBER}" \
    --pipeline-run-id="${PIPELINE_RUN_ID}" \
    --version="$(get_env version)" \
    --name="config"