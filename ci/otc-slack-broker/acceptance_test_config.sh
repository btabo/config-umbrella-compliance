#!/usr/bin/env bash

CONFIG_FOLDER=$1

# secrets
export _DEPLOY_OTC_API_BROKER_SECRET=$(cat $CONFIG_FOLDER/otc-slack-broker_OTC_API_SECRET)
export slack_token=$(cat $CONFIG_FOLDER/otc-slack-broker_slack_token)

#config
export slack_domain=https://idstest.slack.com
export test_tiam_id=test