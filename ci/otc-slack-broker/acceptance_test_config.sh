#!/usr/bin/env bash

# secrets
export _DEPLOY_OTC_API_BROKER_SECRET=$(get_env otc-slack-broker_OTC_API_SECRET)
export slack_token=$(get_env otc-slack-broker_slack_token)

#config
export slack_domain=https://idstest.slack.com
export test_tiam_id=test

# script file
export ACCEPTANCE_TESTS_SCRIPT_FILE=".jobs/test"