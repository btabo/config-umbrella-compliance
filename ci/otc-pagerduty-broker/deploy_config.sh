#!/usr/bin/env bash

# secrets
export SEC_OTC_API_BROKER_SECRET=$(get_env otc-pagerduty-broker_OTC_API_SECRET)
export SEC_ENCRYPTION_KEY=$(get_env otc-pagerduty-broker_ENCRYPTION_KEY)
 
# config 
# none