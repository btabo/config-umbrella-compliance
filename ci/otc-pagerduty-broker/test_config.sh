#!/usr/bin/env bash

# secrets
export OTC_API_BROKER_SECRET=$(get_env otc-pagerduty-broker_OTC_API_SECRET)       
export pagerduty_api_key=$(get_env otc-pagerduty-broker_api_key)
export pagerduty_api_key_2=$(get_env otc-pagerduty-broker_api_key_2)
export ENCRYPTION_KEY=$(get_env otc-pagerduty-broker_ENCRYPTION_KEY)

# config
export TIAM_CLIENT_ID=pagerduty
export services__pagerduty=https://pagerduty.com
export pagerduty_site_name=ibmdevops
export pagerduty_site_name_2=ibmdevops

# script file
export TESTS_SCRIPT_FILE=".jobs/nock"