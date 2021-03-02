#!/usr/bin/env bash

CONFIG_FOLDER=$1

# secrets
export CLOUDANT_IAM_API_KEY=$(cat $CONFIG_FOLDER/otc_CLOUDANT_IAM_API_KEY)
export OTC_API_BROKER_SECRET=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_OTC_API_SECRET)       
export pagerduty_api_key=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_api_key)
export pagerduty_api_key_2=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_api_key_2)
export test_tiam_secret=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_test_tiam_secret)
export ENCRYPTION_KEY=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_ENCRYPTION_KEY)

# config
export CLOUDANT_URL=$(cat $CONFIG_FOLDER/otc-pagerduty-broker_CLOUDANT_URL)
export DOMAIN=stage1.ng.bluemix.net
export PORT='4000'
export url=http://localhost:4000
export TIAM_URL=https://nock-devops-api.stage1.ng.bluemix.net:443/v1/identity
export TIAM_CLIENT_ID=pagerduty
export APP_MEMORY=128M
export services__pagerduty=https://pagerduty.com
export services__otc_api=http://nock-localhost:3400/api/v1
export services__otc_ui=http://nock-localhost:3100/devops
export pagerduty_site_name=ibmdevops
export pagerduty_site_name_2=ibmdevops
export test_tiam_id=test
