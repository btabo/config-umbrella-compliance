#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi
UMBRELLA_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $UMBRELLA_FOLDER/../common/helpers.sh

# do not add to inventory or publish component chart if it cannot be deployed
if ! checkComplianceStatuses; then
    echo "Skipping release stage."
    exit 0
fi

# install cocoa cli	
installCocoa	

# for cocoa cli
export GHE_TOKEN="$(cat $WORKSPACE/git-token)"
export COMMIT_SHA="$(get_env git-commit)"
INVENTORY_REPO=$(get_env TEMP_INVENTORY_REPO "$(get_env inventory-url)" )
GHE_ORG=${INVENTORY_REPO%/*}
export GHE_ORG=${GHE_ORG##*/}
GHE_REPO=${INVENTORY_REPO##*/}
export GHE_REPO=${GHE_REPO%.git}
APP_REPO=$(load_repo app-repo url)
APP_REPO_ORG=${APP_REPO%/*}
export APP_REPO_ORG=${APP_REPO_ORG##*/}
APP_REPO_NAME=${APP_REPO##*/}
export APP_REPO_NAME=${APP_REPO_NAME%.git}
if [ "$APP_REPO_NAME" == "devops-int" ]; then
  export INVENTORY_BRANCH="staging"
else
  export INVENTORY_BRANCH="dev"
fi

# add to inventory
echo "Adding to inventory"
cocoa inventory add \
    --environment="${INVENTORY_BRANCH}" \
    --artifact="$APP_REPO/tree/${COMMIT_SHA}/charts" \
    --repository-url="${APP_REPO}" \
    --commit-sha="${COMMIT_SHA}" \
    --build-number="${BUILD_NUMBER}" \
    --pipeline-run-id="${PIPELINE_RUN_ID}" \
    --version="$(get_env version)" \
    --name="umbrella"
echo "Inventory updated"
echo