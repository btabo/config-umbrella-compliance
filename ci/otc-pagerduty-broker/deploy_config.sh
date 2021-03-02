#!/usr/bin/env bash

CONFIG_FOLDER=$1

# secrets
export SEC_OTC_API_BROKER_SECRET=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_OTC_API_SECRET)
export SEC_ENCRYPTION_KEY=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_ENCRYPTION_KEY)
 
# config 
# none