#!/usr/bin/env bash

# secrets
export _DEPLOY_OTC_API_BROKER_SECRET=$(get_env otc-slack-broker_OTC_API_SECRET)
export ENCRYPTION_KEY=$(get_env otc-slack-broker_ENCRYPTION_KEY)
export slack_webhook=$(get_env otc-slack-broker_slack_webhook)
export archived_slack_webhook=$(get_env otc-slack-broker_archived_slack_webhook)
export slack_user_token=$(get_env otc-slack-broker_slack_user_token)
export channel_id_for_tests=$(get_env otc-slack-broker_channel_id)
export channel_name_for_tests=$(get_env otc-slack-broker_channel_name)

#config
export slack_domain=https://idstest.slack.com
export test_tiam_id=test

# script file
export ACCEPTANCE_TESTS_SCRIPT_FILE=".jobs/test"
