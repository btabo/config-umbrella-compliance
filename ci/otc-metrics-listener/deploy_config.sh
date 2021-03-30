#!/usr/bin/env bash

# secrets
export SEC_AUTH_BSS_BROKER=$(get_env otc-metrics-listener_AUTH_BSS_BROKER)
export SEC_AUTH_CD_BROKER=$(get_env otc-metrics-listener_AUTH_CD_BROKER)
export SEC_CLOUDANT_IAM_API_KEY=$(get_env otc-metrics-listener_CLOUDANT_IAM_API_KEY)
export SEC_CLOUDANT_IAM_API_VERSION=generic-version
export SEC_CLOUDANT_IAM_CLIENT_SECRET_METRICS_LISTENER=$(get_env otc-metrics-listener_CLOUDANT_IAM_CLIENT_SECRET_METRICS_LISTENER)
export SEC_ICD_RABBITMQ_CERT_BASE64=$(get_env otc-metrics-listener_ICD_RABBITMQ_CERT_BASE64)
export SEC_ICD_REDIS_CERT_BASE64=$(get_env otc-metrics-listener_ICD_REDIS_CERT_BASE64)
export SEC_PIPELINE_PAYLOAD_CIPHER_KEY=$(get_env otc-metrics-listener_PIPELINE_PAYLOAD_CIPHER_KEY "")
export SEC_PIPELINE_PAYLOAD_HMAC_KEY=$(get_env otc-metrics-listener_PIPELINE_PAYLOAD_HMAC_KEY "")
export SEC_RABBITMQ_SERVER_URLS=$(get_env otc-metrics-listener_RABBITMQ_SERVER_URLS)
export SEC_REDIS_ENCRYPTION_KEY=$(get_env otc-metrics-listener_REDIS_ENCRYPTION_KEY)
export SEC_REDIS_URLS=$(get_env otc-metrics-listener_REDIS_URLS)
export SEC_TOOLCHAIN_API_KEY=$(get_env otc-metrics-listener_TOOLCHAIN_API_KEY)

# config 
export ENV_ACCOUNT_API_URL=https://accountmanagement.stage1.ng.bluemix.net
export ENV_BLUEMIX_API_URL=https://api.stage1.ng.bluemix.net
export ENV_BLUEMIX_REGION=ibm:ys1:us-south
export ENV_CLOUDANT_URL=https://4db52ca4-20f6-4067-94d0-c098b9a18795-bluemix.cloudantnosqldb.appdomain.cloud
export ENV_CLOUDANT_IAM_CLIENT_ID_METRICS_LISTENER=cd-cloudant-metrics-listener
export ENV_IAM_URL=https://iam.test.cloud.ibm.com
export ENV_METRICS_EVENTS_DB_NAME=metrics-events
export ENV_METRICS_WAREHOUSE_DB_NAME=metrics-warehouse_2
export ENV_NEW_RELIC_ENABLED=false
export ENV_NEW_RELIC_APP_NAME=otc-metrics-listener-ys1
export ENV_OTC_API_DB_NAME=otc-api-toolchains_3
export ENV_PIPELINE_PAYLOAD_ENCRYPT=true
export ENV_TIAM_AUTH_DB_NAME=otc-tiam-authentication_3
export ENV_URL_BSS_BROKER=https://continuous-delivery-bss.us-south.devops.dev.cloud.ibm.com:443
export ENV_URL_CD_BROKER=https://cd-broker.us-south.devops.dev.cloud.ibm.com:443
