#!/usr/bin/env bash

# secrets
export SEC_OTC_API_BROKER_SECRET=$(get_env otc-saucelabs-broker_OTC_API_SECRET)

# config 
export ENV_SAUCELABS_USERNAME="erics_ibm"
export ENV_ORGANIZATION_GUID="83e0652c-20b3-498e-a19c-402f81625c24"
export ENV_TEST_USER="pipeauto@us.ibm.com"
export ENV_TEST_REPORT_USER="theozparksatspooninskull"
export ENV_TEST_REPORT_URL="https://ci-tru.mybluemix.net/php/utilities/uploadTestResults.php"
