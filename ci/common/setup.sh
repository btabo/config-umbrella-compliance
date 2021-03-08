#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export APP_NAME=$(get_env app-name)

# check branch protection and clone app repo
GH_TOKEN=$(cat "$WORKSPACE/git-token")
APP_REPO_URL=$(get_env app-repo-url)
APP_REPO_URL=${APP_REPO_URL%.git}
OWNER=${APP_REPO_URL%/*}
OWNER=${OWNER##*/}
REPO_NAME=${APP_REPO_URL##*/}
REPO_BRANCH=$(get_env app-branch)
curl -u ":$GH_TOKEN" https://github.ibm.com/api/v3/repos/$OWNER/$REPO_NAME/branches/$REPO_BRANCH/protection -XPUT -d '{"required_pull_request_reviews":{"dismiss_stale_reviews":true},"required_status_checks":{"strict":true,"contexts":["tekton/code-branch-protection","tekton/code-unit-tests","tekton/code-cis-check","tekton/code-vulnerability-scan","tekton/code-detect-secrets"]},"enforce_admins":null,"restrictions":null}'
git clone -b $REPO_BRANCH https://$GH_TOKEN@github.ibm.com/$OWNER/$REPO_NAME $APP_NAME

export IDS_USER=idsorg
export IDS_TOKEN=$GH_TOKEN
export GIT_COMMIT=$(git rev-parse HEAD)
export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_TOKEN_BASE64="$(get_env ARTIFACTORY_TOKEN_BASE64)"

cd $APP_NAME
if [ -f "$COMMON_FOLDER/../$APP_NAME/setup.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/setup.sh
else
    echo "$APP_NAME/setup.sh is missing"
    exit 1
fi

echo cat .pipeline_build_id
cat .pipeline_build_id
echo