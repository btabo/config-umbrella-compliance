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
    exit 0
fi

echo "Using the built-in default script for CISO signing"
echo
${ONE_PIPELINE_PATH}/internal/ciso/sign_icr
