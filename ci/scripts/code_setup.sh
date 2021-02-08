#!/usr/bin/env bash

set -euo pipefail

export IDS_USER=idsorg
export IDS_TOKEN=$GH_TOKEN
export GIT_COMMIT=$(git rev-parse HEAD)
export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_TOKEN_BASE64="$(cat /config/ARTIFACTORY_TOKEN_BASE64)"
chmod +x .jobs/build
.jobs/build

echo cat .pipeline_build_id
cat .pipeline_build_id
echo