#!/usr/bin/env bash

# secrets
export SEC_OTC_API_BROKER_SECRET=$(get_env otc-slack-broker_OTC_API_SECRET)
export SEC_ENCRYPTION_KEY=$(get_env otc-slack-broker_ENCRYPTION_KEY)
export SEC_TOOLCHAIN_API_KEY=$(get_env otc-slack-broker_TOOLCHAIN_API_KEY)

# config 
# kms_info
export ENV_ENABLE_KMS=true
export ENV_KMS_REGION=dev
export ENV_SENTINEL_KMS_URL=https://qa.us-south.kms.test.cloud.ibm.com
export ENV_SENTINEL_KMS_INSTANCE_ID=fd3d423f-f1c3-4af0-bf40-569c60f22376
export ENV_SENTINEL_ROOT_KEY_ID=57e8bb2b-fa76-48f5-a323-35750fef17dc
export ENV_SENTINEL_TOOLCHAIN_CRN=crn:v1:staging:public:toolchain:us-south:a/79df5267605f4fa8aa2db7b8dfcf2197:c14cc969-83c8-462d-89aa-c9722aef5be2::
export ENV_DEFAULT_WDEK=eyJjaXBoZXJ0ZXh0IjoiS2h0THNlTVVmZjZtcFZnUTBjNW1iTCs3a2NPUCtiMFJUVUhHZXhONWFSTmNEdksyNnVqVVA0aTlLQnM9IiwiaXYiOiJOUzZMWmxPVmxxWmNCZi9WIiwidmVyc2lvbiI6IjQuMC4wIiwiaGFuZGxlIjoiNTdlOGJiMmItZmE3Ni00OGY1LWEzMjMtMzU3NTBmZWYxN2RjIn0=
export ENV_ENABLE_KMS_EVENTS=true
export ENV_IAM_URL=https://iam.test.cloud.ibm.com
export ENV_ENABLE_NEW_RELIC=true
export ENV_ENABLE_SECRET_PICKER=true
export ENV_ENV_ID=ibm:ys1:us-south
export ENV_KMS_EVENT_WEBHOOK=https://otc-slack-broker.us-south.devops.dev.cloud.ibm.com/slack-broker/api/v1/events
export ENV_NEW_RELIC_APP_NAME=otc-slack-broker-ys1
export ENV_SECRETS_API_URL=https://otc-ui.us-south.devops.dev.cloud.ibm.com/devops/api/v1/secrets
# none
