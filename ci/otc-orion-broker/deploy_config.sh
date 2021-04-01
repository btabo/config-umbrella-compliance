#!/usr/bin/env bash

# secrets
export SEC_CLOUDANT_IAM_API_VERSION="generic-version"
export SEC_CLOUDANT_IAM_CLIENT_SECRET_ORION="$(get_env otc-orion-broker_CLOUDANT_IAM_CLIENT_SECRET_ORION)"
export SEC_OTC_API_BROKER_SECRET="$(get_env otc-orion-broker_OTC_API_BROKER_SECRET)"

# config 
export ENV_CLOUDANT_IAM_CLIENT_ID_ORION="cd-cloudant-orion"
export ENV_OTC_API="http://otc-api/api/v1/"
export ENV_OTC_API_BROKER_ID="orion"

# none
