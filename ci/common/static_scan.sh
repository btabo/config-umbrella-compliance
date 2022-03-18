#!/usr/bin/env bash

export APP_NAME=$1
REPO_FOLDER=$2

if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $COMMON_FOLDER/../../helpers.sh

if [ -z $APP_NAME ]; then
    export APP_NAME=$(get_env app-name)
fi
if [ -f $COMMON_FOLDER/../$APP_NAME/static_scan.sh ]; then
    source $COMMON_FOLDER/../$APP_NAME/static_scan.sh
    exit $?
fi

if [ -z $REPO_FOLDER ]; then
    REPO_FOLDER=$(load_repo app-repo path)
fi
cd $WORKSPACE

# secrets and config specific to the component
if [ -f "$COMMON_FOLDER/../$APP_NAME/static_scan_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/static_scan_config.sh
fi

# run scan
echo "Using the built-in default script for static scan /opt/commons/static-scan/run.sh"
echo
# TODO: enable, see https://github.ibm.com/org-ids/roadmap/issues/17511
/opt/commons/static-scan/run.sh
echo