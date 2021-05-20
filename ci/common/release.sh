#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export APP_NAME=$(get_env app-name)
if [ -f $COMMON_FOLDER/../$APP_NAME/release.sh ]; then
    source $COMMON_FOLDER/../$APP_NAME/release.sh
    exit 0
fi

source $COMMON_FOLDER/helpers.sh

# do not add to inventory or publish component chart if it cannot be deployed
if ! checkComplianceStatuses; then
    echo "Skipping release stage."
    exit 0
fi

REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE/$REPO_FOLDER

# clone otc-deploy and devops-config if needed
cloneOtcDeploy

# secrets and config
if [ -f "$COMMON_FOLDER/../$APP_NAME/release_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/release_config.sh
fi

# to pass helm lint --strict
export SEC_CLOUDANT_IAM_API_KEY="topasshelmlintstrict"
export SEC_OTC_API_BROKER_SECRET="topasshelmlintstrict"
export ENV_CLOUDANT_URL="topasshelmlintstrict"
export ENV_services__otc_ui="topasshelmlintstrict"
export ENV_services__otc_ui_env_id="topasshelmlintstrict"
export ENV_url="topasshelmlintanddryrun"
export ENV_NEW_RELIC_APP_NAME="topasshelmlintanddryrun"
export ENV_TIAM_URL="topasshelmlintanddryrun"
export ENV_PORT="topasshelmlintanddryrun"
export GLOBAL_ENV_SECGRP="topasshelmlintanddryrun"
export PIPELINE_KUBERNETES_CLUSTER_NAME="topasshelmlintanddryrun"

# for building helm chart
export IDS_USER="idsorg"
export IDS_TOKEN=$(get_env git-token)
export BRANCH=$(load_repo app-repo branch)
if [ "$BRANCH" == "integration" ]; then
    export DOMAIN="stage.us-south.devops.cloud.ibm.com"
    export NUM_INSTANCES="3"
    export CHART_REPO="devops-int"
    export PRUNE_CHART_REPO="false"
else
    export DOMAIN="devops.dev.us-south.bluemix.net"
    export NUM_INSTANCES="1"
    export CHART_REPO="devops-dev"
    export PRUNE_CHART_REPO="true"
fi
export NAMESPACE="opentoolchain"
export RELEASE_NAME="$APP_NAME"
export MAJOR_VERSION="1"
export MINOR_VERSION="0"
export CHART_ORG="ids-env"
export LOGICAL_APP_NAME="$APP_NAME"
export BUILD_PREFIX="$BRANCH"
export ENV_BUILD_TIMESTAMP=$(date +%s%3N)
export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_API_KEY="$(get_env otc_ARTIFACTORY_API_KEY)"

# override chart org and repo name if specified
TEMP_CHART_REPO_URL=$(get_env TEMP_CHART_REPO_URL "")
if [ "$TEMP_CHART_REPO_URL" ]; then
    CHART_REPO=$(basename $TEMP_CHART_REPO_URL)
    CHART_ORG=$(basename $(dirname $TEMP_CHART_REPO_URL))
fi

echo "Cheking helm version"
export IC_1308775_API_KEY=$(get_env otc_IC_1308775_API_KEY)
. otc-deploy/k8s/scripts/login/clusterLogin.sh "otc-dal12-test" "otc"
. otc-deploy/k8s/scripts/helpers/checkHelmVersion.sh
echo "Done checking helm version"
echo

# compute BUILD_NUMBER
echo "Finding a suitable BUILD_NUMBER for helm chart revision number"
git clone --depth 1 https://$IDS_USER:$IDS_TOKEN@github.ibm.com/ids-env/$CHART_REPO || true
NEXT_VERSION=$(ls -v ${CHART_REPO}/charts/${LOGICAL_APP_NAME}* 2> /dev/null | tail -n -1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | awk -F'.' -v OFS='.' '{$3=sprintf("%d",++$3)}7')
if [ -z "$NEXT_VERSION" ]; then
    NEXT_VERSION="$MAJOR_VERSION.$MINOR_VERSION.0"
fi
export BUILD_NUMBER=$(echo "$NEXT_VERSION" | awk -F. '{print $3}')
rm -r -f $CHART_REPO
echo "Next helm chart version will be $NEXT_VERSION"
echo "Computed BUILD_NUMBER is $BUILD_NUMBER"
echo

# build and publish component chart to solution repo
echo "Publishing component chart to solution repo"
chmod u+x otc-deploy/k8s/scripts/ci/publishHelmChart.sh
./otc-deploy/k8s/scripts/ci/publishHelmChart.sh
echo "Done publishing component chart"
echo

# install cocoa cli	
installCocoa	

# for cocoa cli
export GHE_TOKEN="$(get_env git-token)"
export COMMIT_SHA="$(get_env git-commit)"
if [ "$BRANCH" == "integration" ]; then
  export INVENTORY_BRANCH="staging"
else
  export INVENTORY_BRANCH="dev"
fi
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

# add to inventory
echo "Adding to inventory"
CHART_VERSION=$(yq r -j "k8s/$APP_NAME/Chart.yaml" | jq -r '.version')
ARTIFACT="https://github.ibm.com/$CHART_ORG/$CHART_REPO/blob/master/charts/$APP_NAME-$CHART_VERSION.tgz"
IMAGE_NAME="$(load_artifact ${APP_NAME}_image name)"
SIGNATURE="$(get_env signature "")"
PROVENANCE="$(load_repo app-repo url)/tree/${COMMIT_SHA}"
APP_ARTIFACTS='{ "image": "'${IMAGE_NAME}'" }'
cocoa inventory add \
    --environment="${INVENTORY_BRANCH}" \
    --name="${APP_NAME}" \
    --artifact="${ARTIFACT}" \
    --repository-url="${APP_REPO}" \
    --commit-sha="${COMMIT_SHA}" \
    --build-number="${BUILD_NUMBER}" \
    --pipeline-run-id="${PIPELINE_RUN_ID}" \
    --version="$CHART_VERSION" \
    --app-artifacts="${APP_ARTIFACTS}" \
    --type="helm-chart" \
    --sha256="${COMMIT_SHA}" \
    --provenance="${PROVENANCE}" \
    --signature="${SIGNATURE}"
echo "Inventory updated"
echo