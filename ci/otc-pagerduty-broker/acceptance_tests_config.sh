#!/usr/bin/env bash
OTC_PAGERDUTY_BROKER_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# same config as for test cluster deployment
. $OTC_PAGERDUTY_BROKER_FOLDER/deploy_config.sh $CONFIG_FOLDER

export TIAM_URL=$ENV_TIAM_URL
export _DEPLOY_url=$ENV_url
export _DEPLOY_OTC_API_BROKER_SECRET=$SEC_OTC_API_BROKER_SECRET
