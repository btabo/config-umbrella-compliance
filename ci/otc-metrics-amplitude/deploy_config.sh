#!/usr/bin/env bash

# secrets
export SEC_AMPLITUDE_API_KEY=$(get_env otc-metrics-amplitude_AMPLITUDE_API_KEY)
export SEC_CLOUDANT_IAM_API_KEY=$(get_env otc-metrics-amplitude_CLOUDANT_IAM_API_KEY)
export SEC_CLOUDANT_IAM_API_VERSION=generic-version
export SEC_CLOUDANT_IAM_CLIENT_SECRET_METRICS_AMPLITUDE=$(get_env otc-metrics-amplitude_CLOUDANT_IAM_CLIENT_SECRET)

# config 
export ENV_ARGS=--doit
export ENV_BLUEMIX_REGION=ibm:ys1:us-south
export ENV_CLOUDANT_URL=https://4db52ca4-20f6-4067-94d0-c098b9a18795-bluemix.cloudantnosqldb.appdomain.cloud
export ENV_CLOUDANT_IAM_CLIENT_ID_METRICS_AMPLITUDE=cd-cloudant-metrics-amplitude
export ENV_METRICS_EVENTS_DB_NAME=metrics-events
export ENV_METRICS_WAREHOUSE_DB_NAME=metrics-warehouse_2
export ENV_OTC_API_DB_NAME=otc-api-toolchains_3
export ENV_SEGMENT_SOURCE_KEY=xCckVKyJ8ffVrqzmICZfUx2ZUyXg7ftS
export ENV_TIAM_AUTH_DB_NAME=otc-tiam-authentication_3
export ENV_LAG_MINS=5
