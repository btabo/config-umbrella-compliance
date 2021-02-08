#!/usr/bin/env bash

set -euo pipefail
CONFIG_FOLDER=${1:-"/config"}

export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_TOKEN_BASE64="$(cat $CONFIG_FOLDER/ARTIFACTORY_TOKEN_BASE64)"
chmod +x .jobs/nock
.jobs/nock