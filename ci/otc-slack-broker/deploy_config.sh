#!/usr/bin/env bash

# secrets
export SEC_OTC_API_BROKER_SECRET=$(get_env otc-slack-broker_OTC_API_SECRET)
export SEC_ENCRYPTION_KEY=$(get_env otc-slack-broker_ENCRYPTION_KEY)

# config 
# kms_info
export ENV_DEFAULT_WDEK=eyJjaXBoZXJ0ZXh0IjoiS2h0THNlTVVmZjZtcFZnUTBjNW1iTCs3a2NPUCtiMFJUVUhHZXhONWFSTmNEdksyNnVqVVA0aTlLQnM9IiwiaXYiOiJOUzZMWmxPVmxxWmNCZi9WIiwidmVyc2lvbiI6IjQuMC4wIiwiaGFuZGxlIjoiNTdlOGJiMmItZmE3Ni00OGY1LWEzMjMtMzU3NTBmZWYxN2RjIn0=
export ENV_IAM_URL=https://iam.test.cloud.ibm.com
# none
