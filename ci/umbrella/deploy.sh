#!/usr/bin/env bash

# since we're not using otc-deploy image any longer, need to install scripts manually
UMBRELLA_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $UMBRELLA_FOLDER/../common/helpers.sh
cloneOtcDeploy
cp -r otc-deploy/k8s/scripts/* /
cp -r devops-config/otc-deploy/* /otc-config

#source ./cd/deploy.sh
