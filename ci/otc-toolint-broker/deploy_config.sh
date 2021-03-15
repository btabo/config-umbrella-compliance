#!/usr/bin/env bash

# secrets
export SEC_ENCRYPTION_KEY=$(get_env otc-toolint-broker_ENCRYPTION_KEY)
export SEC_OTC_API_BROKER_SECRET=$(get_env otc-toolint-broker_OTC_API_SECRET)

# config 
export ENV_DLMS_WS_HOST=https://devops-api.us-south.devops.dev.cloud.ibm.com
export ENV_OTC_API_BROKER_ID=jenkins
export ENV_OTC_API_URL=https://otc-api.devops.dev.us-south.bluemix.net/api/v1
export ENV_DATABASE_NAME=test-toolint-broker
export ENV_TOOLCHAIN_BASE_URL=https://dev-console-dal10.stage1.bluemix.net/devops/toolchains
export ENV_WEBHOOK_PUBLISH_URL=api.devops.dev.us-south.bluemix.net
export ENV_CF_API_URL=https://api.stage1.ng.bluemix.net/v2
export ENV_CLOUD_CONNECT_URL=https://uccloud-connect-stage1.stage1.mybluemix.net/api/v1/
export ENV_CLOUD_SYNC_REG_URL=https://uccloud-sync-reg-stage1.stage1.mybluemix.net/api/v1/
export ENV_CLOUD_SYNC_STORE_URL=https://uccloud-sync-store-stage1.stage1.mybluemix.net/api/v1/
export ENV_MCC_URL=https://mccp.ng.bluemix.net
export ENV_TIAM_ID=test
export ENV_TIAM_URL=https://tiam.devops.dev.us-south.bluemix.net/identity/v1
export ENV_url=otc-toolint-broker.devops-dal12-test.us-south.containers.mybluemix.net