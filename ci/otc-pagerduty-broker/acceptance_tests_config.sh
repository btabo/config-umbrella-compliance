#!/usr/bin/env bash
OTC_PAGERDUTY_BROKER_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# same config as for test cluster deployment
. $OTC_PAGERDUTY_BROKER_FOLDER/deploy_config.sh