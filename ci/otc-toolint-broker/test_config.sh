#!/usr/bin/env bash

# secrets
export OTC_API_BROKER_SECRET=$(get_env otc-toolint-broker_OTC_API_SECRET)
export ENCRYPTION_KEY=$(get_env otc-toolint-broker_ENCRYPTION_KEY)
export ENABLE_KMS=true
unset CLOUDANT_IAM_API_KEY
unset test_tiam_secret

# config
export DLMS_WS_HOST=https://devops-api.us-south.devops.dev.cloud.ibm.com
export JIRA_API_PATH=/rest/api/2/project/
export JIRA_DEFAULT_PROJECT_ROLE=PROJECT_LEAD
export JIRA_DEFAULT_PROJECT_TYPE=software
export OTC_API_BROKER_ID=jenkins
export OTC_API_URL=https://otc-api.stage1.ng.bluemix.net/api/v1
export SALT_LENGTH='32'
export TIAM_URL=https://devops-api.stage1.ng.bluemix.net/v1/identity
export TOOLCHAIN_BASE_URL=https://dev-console.stage1.ng.bluemix.net/devops/toolchains
export TRACEABILITY_PUBLISH_ROUTE=/toolint-broker/api/v1/traceability/
export WEBHOOK_PUBLISH_ROUTE=/toolint-broker/api/v1/messaging/webhook/publish
export WEBHOOK_PUBLISH_URL=devops-api.stage1.ng.bluemix.net
export url=http://localhost
export TEST_ENV=_mock
export IAM_CLIENT_ID=otc
export IAM_URL=https://iam.test.cloud.ibm.com
export CF_API_URL=https://api.stage1.ng.bluemix.net/v2
export MCCP_URL=https://mccp.ng.bluemix.net
unset APP_MEMORY
unset CLOUDANT_URL
unset DOMAIN
unset services__otc_api
unset services__otc_ui
unset test_tiam_id

# script file
export TESTS_SCRIPT_FILE=".jobs/mocha-tests"
