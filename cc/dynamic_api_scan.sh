#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

CC_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $CC_FOLDER/../helpers.sh

loopThroughApps "source $CC_FOLDER/../ci/common/dynamic_api_scan.sh"