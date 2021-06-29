#!/usr/bin/env bash

# do not add to inventory if it cannot be deployed
source ./ci/common/helpers.sh
if ! checkComplianceStatuses; then
    echo "Skipping release stage."
    exit 0
fi

cd $WORKSPACE/devops-config

export COMMIT_SHA="$(get_env git-commit)"

# install scripts helpers
cloneOtcDeploy
source otc-deploy/k8s/scripts/artifactory/helpers.sh
source otc-deploy/k8s/scripts/umbrella/helpers.sh

# for cocoa cli
export GHE_TOKEN=$(get_env git-token)
APP_REPO=$(load_repo app-repo url)
INVENTORY_REPO_URL=$(get_env TEMP_INVENTORY_REPO "$(get_env inventory-url)" )
INVENTORY_ORG=${INVENTORY_REPO_URL%/*}
INVENTORY_ORG=${INVENTORY_ORG##*/}
INVENTORY_REPO=${INVENTORY_REPO_URL##*/}
INVENTORY_REPO=${INVENTORY_REPO%.git}

# detect the inventory branches that should be updated
export IDS_TOKEN=$GHE_TOKEN
HAS_DEV_CHANGES="false"
detectDevopsConfigChange HAS_DEV_CHANGES "dev" $COMMIT_SHA $INVENTORY_ORG $INVENTORY_REPO
HAS_STAGING_CHANGES="false"
detectDevopsConfigChange HAS_STAGING_CHANGES "staging" $COMMIT_SHA $INVENTORY_ORG $INVENTORY_REPO
if [ "$HAS_DEV_CHANGES" == "false" ] && [ "$HAS_STAGING_CHANGES" == "false" ]; then
    exit 0
fi

# install cocoa cli	
export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_API_KEY="$(get_env otc_ARTIFACTORY_API_KEY)"
installCocoa	

# prepare tgz file
VERSION=$(date -u +%Y%m%d%H%M%Z)
TGZ_FILE_NAME="config-$VERSION.tgz"
tar -zcf $TGZ_FILE_NAME ./devops-config/environments

echo "Adding to inventory"
if [ "$HAS_DEV_CHANGES" == "true" ]; then
    uploadToArtifactory ARTIFACTORY_SHA_256 ARTIFACTORY_DOWNLOAD_URI "$TGZ_FILE_NAME" "wcp-otc-common-team-generic-local" "helm-charts/dev/$TGZ_FILE_NAME" $ARTIFACTORY_API_KEY    
    cocoa inventory add \
        --org="$INVENTORY_ORG" \
        --repo="$INVENTORY_REPO" \
        --environment="dev" \
        --name="config" \
        --artifact="$TGZ_FILE_NAME" \
        --repository-url="${APP_REPO}" \
        --commit-sha="${COMMIT_SHA}" \
        --build-number="${BUILD_NUMBER}" \
        --pipeline-run-id="${PIPELINE_RUN_ID}" \
        --version="${VERSION}" \
        --type="config" \
        --sha256="${ARTIFACTORY_SHA_256}" \
        --provenance="${ARTIFACTORY_DOWNLOAD_URI}"
fi
if [ "$HAS_STAGING_CHANGES" == "true" ]; then
    uploadToArtifactory ARTIFACTORY_SHA_256 ARTIFACTORY_DOWNLOAD_URI "$TGZ_FILE_NAME" "wcp-otc-common-team-generic-local" "helm-charts/prod/$TGZ_FILE_NAME" $ARTIFACTORY_API_KEY    
    cocoa inventory add \
        --org="$INVENTORY_ORG" \
        --repo="$INVENTORY_REPO" \
        --environment="staging" \
        --name="config" \
        --artifact="$TGZ_FILE_NAME" \
        --repository-url="${APP_REPO}" \
        --commit-sha="${COMMIT_SHA}" \
        --build-number="${BUILD_NUMBER}" \
        --pipeline-run-id="${PIPELINE_RUN_ID}" \
        --version="${VERSION}" \
        --type="config" \
        --sha256="${ARTIFACTORY_SHA_256}" \
        --provenance="${ARTIFACTORY_DOWNLOAD_URI}"
fi
echo "Inventory updated"
echo
