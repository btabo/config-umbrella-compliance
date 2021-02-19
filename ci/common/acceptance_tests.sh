#!/usr/bin/env bash

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FOLDER=${1:-"/config"}

export APP_NAME=$(cat $CONFIG_FOLDER/app-name)
if [ -f "$COMMON_FOLDER/../$APP_NAME/acceptance_tests_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/acceptance_tests_config.sh $CONFIG_FOLDER
fi

echo "BUILD_NUMBER=$BUILD_NUMBER"
echo ".pipeline_build_id=$(<.pipeline_build_id)"
.jobs/test
