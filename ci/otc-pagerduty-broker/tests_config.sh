#!/usr/bin/env bash

CONFIG_FOLDER=$1

# secrets
export OTC_API_BROKER_SECRET=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_OTC_API_SECRET)       
export pagerduty_api_key=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_api_key)
export pagerduty_api_key_2=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_api_key_2)
export ENCRYPTION_KEY=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_ENCRYPTION_KEY)

# config
export TIAM_CLIENT_ID=pagerduty
export services__pagerduty=https://pagerduty.com
export pagerduty_site_name=ibmdevops
export pagerduty_site_name_2=ibmdevops
