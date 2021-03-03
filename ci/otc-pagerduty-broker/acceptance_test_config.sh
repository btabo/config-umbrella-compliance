#!/usr/bin/env bash

CONFIG_FOLDER=$1

# secrets
export pagerduty_api_key=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_api_key)
export pagerduty_api_key_2=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_api_key_2)
export test_tiam_secret=$(cat $CONFIG_FOLDER/otc_test_tiam_secret)
export _DEPLOY_OTC_API_BROKER_SECRET=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_OTC_API_SECRET)

# config
export pagerduty_site_name="ibmdevops"
export pagerduty_site_name_2="ibmdevops"
export test_tiam_id="test"