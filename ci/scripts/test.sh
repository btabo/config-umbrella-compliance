#!/usr/bin/env bash

set -euo pipefail

export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_TOKEN_BASE64="$(cat /config/ARTIFACTORY_TOKEN_BASE64)"
chmod +x .jobs/nock
.jobs/nock