#!/usr/bin/env bash

CONFIG_FOLDER=$1

# secrets
export OTC_API_BROKER_SECRET=$(cat $CONFIG_FOLDER/otc-slack-broker_OTC_API_SECRET)
export slack_token=$(cat $CONFIG_FOLDER/otc-slack-broker_slack_token)

# config
export TIAM_CLIENT_ID=slack
export services__slack_api=https://slack.com/api
export slack_domain=https://idstest.slack.com

# unused?
export icons__toolchain=https://cloud.ibm.com/devops/graphics/toolchains.svg
export icons__pipeline=https://cloud.ibm.com/devops/pipelines/graphics/pipeline.png