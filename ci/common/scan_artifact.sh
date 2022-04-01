#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

export APP_NAME=$1
REPO_FOLDER=$2
BRANCH=$3 #unused
ARTIFACT=$4

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z $APP_NAME ]; then
    export APP_NAME=$(get_env app-name)
fi
if [ -z $REPO_FOLDER ]; then
    REPO_FOLDER=$(load_repo app-repo path)
fi
if [ -z $ARTIFACT ]; then
    ARTIFACT="app-image"
fi
cd $WORKSPACE/$REPO_FOLDER

function ciScanArtifact() {
    if [ -f $COMMON_FOLDER/../$APP_NAME/scan_artifact.sh ]; then
        source $COMMON_FOLDER/../$APP_NAME/scan_artifact.sh
        return $?
    fi

    echo "Using the built-in default script for scan artifact /opt/commons/icr-va/scan.sh"
    echo
    source /opt/commons/icr-va/scan.sh # https://github.ibm.com/open-toolchain/compliance-commons/blob/master/icr-va/scan.sh

    local image="$(load_artifact "$ARTIFACT" "name")"
    local digest="$(load_artifact "$ARTIFACT" "digest")"
    local name="$(echo "$ARTIFACT" | awk '{print $1}')"

    start_va_scan "$name" "$image" "$digest"
    echo
}

ciScanArtifact