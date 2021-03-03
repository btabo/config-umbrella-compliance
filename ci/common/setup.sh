#!/usr/bin/env bash

CONFIG_FOLDER=${1:-"/config"}

export IDS_USER=idsorg
export IDS_TOKEN=$GH_TOKEN
export GIT_COMMIT=$(git rev-parse HEAD)
export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_TOKEN_BASE64="$(cat $CONFIG_FOLDER/ARTIFACTORY_TOKEN_BASE64)"

# temp
echo ==============================================
env | sort
echo ==============================================
echo

chmod +x .jobs/build
.jobs/build

echo cat .pipeline_build_id
cat .pipeline_build_id
echo