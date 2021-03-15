#!/usr/bin/env bash

# secrets
export _DEPLOY_OTC_API_BROKER_SECRET=$(get_env otc-pagerduty-broker_OTC_API_SECRET)

# config
export IAM_CLIENT_ID=otc

# script file
export ACCEPTANCE_TESTS_SCRIPT_FILE=".jobs/test"