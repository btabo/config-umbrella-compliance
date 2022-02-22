#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export APP_NAME=$(get_env app-name)
if [ -f $COMMON_FOLDER/../$APP_NAME/sign_artifact.sh ]; then
    source $COMMON_FOLDER/../$APP_NAME/sign_artifact.sh
    exit $?
fi

echo "Using the built-in default script for CISO signing"
echo
${ONE_PIPELINE_PATH}/internal/ciso/sign_icr # https://github.ibm.com/one-pipeline/compliance-baseimage/blob/master/one-pipeline/internal/ciso/sign_icr
