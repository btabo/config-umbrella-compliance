#!/usr/bin/env bash

# secrets
export SEC_OTC_API_BROKER_SECRET=$(get_env otc-pagerduty-broker_OTC_API_SECRET)
export SEC_ENCRYPTION_KEY=$(get_env otc-pagerduty-broker_ENCRYPTION_KEY)
 
# config 
# kms_info
export ENV_DEFAULT_WDEK=eyJjaXBoZXJ0ZXh0IjoidTNaSTF6eFppRVNoYUNaMWYxa3IzK2lqRDdCeXI5TFROQ2dxQlNuSWw4R2FKTm8xZFo5VzM4Wk4xSUk9IiwiaXYiOiJEanRaWTQ0VkQyMHAxM3RZIiwidmVyc2lvbiI6IjQuMC4wIiwiaGFuZGxlIjoiNTdlOGJiMmItZmE3Ni00OGY1LWEzMjMtMzU3NTBmZWYxN2RjIn0=
export ENV_IAM_URL=https://iam.test.cloud.ibm.com
# none