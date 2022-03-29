#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export APP_NAME=$1
if [ -z $APP_NAME ]; then
    export APP_NAME=$(get_env app-name)
fi

function ciScanArtifact() {
    if [ -f $COMMON_FOLDER/../$APP_NAME/scan_artifact.sh ]; then
        source $COMMON_FOLDER/../$APP_NAME/scan_artifact.sh
        return $?
    fi

    echo "Using the built-in default script for scan artifact /opt/commons/scan-artifact/scan.sh"
    echo
    /opt/commons/scan-artifact/scan.sh # https://github.ibm.com/open-toolchain/compliance-commons/blob/master/scan-artifact/scan.sh
    echo
}

ciScanArtifact