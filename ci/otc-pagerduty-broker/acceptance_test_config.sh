#!/usr/bin/env bash

# secrets
export pagerduty_api_key=$(get_env otc-pagerduty-broker_api_key)
export pagerduty_api_key_2=$(get_env otc-pagerduty-broker_api_key_2)
export _DEPLOY_OTC_API_BROKER_SECRET=$(get_env otc-pagerduty-broker_OTC_API_SECRET)

# config
export pagerduty_site_name="ibmdevops"
export pagerduty_site_name_2="ibmdevops"
export test_tiam_id="test"

# script file
export ACCEPTANCE_TESTS_SCRIPT_FILE=".jobs/test"