#!/usr/bin/env bash

CONFIG_FOLDER=$1

# secrets
export SEC_OTC_API_BROKER_SECRET=$(cat $CONFIG_FOLDER/otc-slack-broker_OTC_API_SECRET)
 
# config 
# none