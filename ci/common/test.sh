#!/usr/bin/env bash

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

set -euo pipefail
CONFIG_FOLDER=${1:-"/config"}

APP_NAME=$(cat $CONFIG_FOLDER/app-name)
if [ -f "$COMMON_FOLDER/../$APP_NAME/test_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/test_config.sh $CONFIG_FOLDER
fi

export ARTIFACTORY_ID=idsorg@us.ibm.com
export ARTIFACTORY_TOKEN_BASE64="$(cat $CONFIG_FOLDER/ARTIFACTORY_TOKEN_BASE64)"
chmod +x .jobs/nock
.jobs/nock