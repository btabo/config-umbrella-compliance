#!/usr/bin/env bash

# secrets
export OTC_API_BROKER_SECRET=$(get_env otc-toolint-broker_OTC_API_SECRET)
export ENCRYPTION_KEY=$(get_env otc-toolint-broker-test_ENCRYPTION_KEY)
export TOOLCHAIN_API_KEY=$(get_env otc-toolint-broker_TOOLCHAIN_API_KEY)
unset CLOUDANT_IAM_API_KEY
unset test_tiam_secret

# kms_info
export ENABLE_KMS=false
export KMS_REGION=dev
export SENTINEL_KMS_URL=https://qa.us-south.kms.test.cloud.ibm.com
export SENTINEL_KMS_INSTANCE_ID=fd3d423f-f1c3-4af0-bf40-569c60f22376
export SENTINEL_ROOT_KEY_ID=57e8bb2b-fa76-48f5-a323-35750fef17dc
export SENTINEL_TOOLCHAIN_CRN=crn:v1:staging:public:toolchain:us-south:a/79df5267605f4fa8aa2db7b8dfcf2197:c14cc969-83c8-462d-89aa-c9722aef5be2::
export DEFAULT_WDEK=eyJjaXBoZXJ0ZXh0IjoiSmU1SFdiWkVmZEJ5M1E4K0NRVUd4SDNlTWJxZEoyQ3B0RFp1ZmVMeGNxR3FrSEg4dU4rR2txb3dpblk9IiwiaXYiOiIxbWpnTXE0V0N0SlAxT1Z1IiwidmVyc2lvbiI6IjQuMC4wIiwiaGFuZGxlIjoiNTdlOGJiMmItZmE3Ni00OGY1LWEzMjMtMzU3NTBmZWYxN2RjIn0=
export IAM_URL=https://iam.test.cloud.ibm.com

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
