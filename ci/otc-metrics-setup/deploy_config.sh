#!/usr/bin/env bash

# secrets
export SEC_CLOUDANT_IAM_API_KEY=$(get_env otc-metrics-setup_CLOUDANT_IAM_API_KEY)
export SEC_CLOUDANT_IAM_API_VERSION=generic-version
export SEC_CLOUDANT_IAM_CLIENT_SECRET_METRICS_SETUP=$(get_env otc-metrics-setup_CLOUDANT_IAM_CLIENT_SECRET)

# config 
export ENV_CLOUDANT_URL=https://4db52ca4-20f6-4067-94d0-c098b9a18795-bluemix.cloudantnosqldb.appdomain.cloud
export ENV_CLOUDANT_IAM_CLIENT_ID_METRICS_SETUP=cd-cloudant-metrics-setup
export ENV_FUNCTIONAL_USERID=thanathilacespentedclone
export ENV_METRICS_EVENTS_DB_NAME=metrics-events
export ENV_METRICS_WAREHOUSE_DB_NAME=metrics-warehouse_2
export ENV_SECGRP=GRP3DEVS
