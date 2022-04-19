#!/usr/bin/env bash

# secrets
export SEC_OTC_API_BROKER_SECRET=$(get_env otc-saucelabs-broker_OTC_API_SECRET)

# config 
export ENV_SAUCELABS_USERNAME="erics_ibm"
export ENV_ORGANIZATION_GUID="83e0652c-20b3-498e-a19c-402f81625c24"
export ENV_TEST_USER="pipeauto@us.ibm.com"
export ENV_TEST_REPORT_USER="theozparksatspooninskull"
export ENV_TEST_REPORT_URL="https://ci-tru.mybluemix.net/php/utilities/uploadTestResults.php"
unset ENV_LOG4J_LEVEL
unset ENV_services__otc_api
unset ENV_services__otc_ui
unset ENV_services__otc_ui_env_id
unset ENV_TIAM_URL

# kms_info
export ENV_DEFAULT_WDEK=eyJjaXBoZXJ0ZXh0IjoidTNaSTF6eFppRVNoYUNaMWYxa3IzK2lqRDdCeXI5TFROQ2dxQlNuSWw4R2FKTm8xZFo5VzM4Wk4xSUk9IiwiaXYiOiJEanRaWTQ0VkQyMHAxM3RZIiwidmVyc2lvbiI6IjQuMC4wIiwiaGFuZGxlIjoiNTdlOGJiMmItZmE3Ni00OGY1LWEzMjMtMzU3NTBmZWYxN2RjIn0=
export ENV_IAM_URL=https://iam.test.cloud.ibm.com