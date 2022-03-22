#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

CC_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $CC_FOLDER/../helpers.sh

# woraround CRA setup script impossible for each component
# see https://ibm-cloudplatform.slack.com/archives/CFQHG5PP1/p1647936017705939
set_env cra-custom-script-path "../one-pipeline-config-repo/cc/cra-custom-script.sh" # use relative path, see https://ibm-cloudplatform.slack.com/archives/CFQHG5PP1/p1647963195786279

loopThroughApps "source $CC_FOLDER/../ci/common/setup.sh CC"