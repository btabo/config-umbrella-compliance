#!/usr/bin/env bash

# secrets
export OTC_API_BROKER_SECRET=$(get_env otc-slack-broker_OTC_API_SECRET)
export slack_webhook=$(get_env otc-slack-broker_slack_webhook)
export slack_user_token=$(get_env otc-slack-broker_slack_user_token)
export ENCRYPTION_KEY=$(get_env otc-slack-broker_ENCRYPTION_KEY)

# config
export TIAM_CLIENT_ID=slack
export services__slack_api=https://slack.com/api
export slack_domain=https://idstest.slack.com
export PORT='4000'
export url=http://localhost:$PORT

# unused?
export icons__toolchain=https://cloud.ibm.com/devops/graphics/toolchains.svg
export icons__pipeline=https://cloud.ibm.com/devops/pipelines/graphics/pipeline.png

# script file
export TESTS_SCRIPT_FILE=".jobs/nock"
