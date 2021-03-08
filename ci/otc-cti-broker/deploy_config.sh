#!/usr/bin/env bash

# secrets
export SEC_OTC_API_BROKER_SECRET=$(get_env otc-cti_OTC_API_SECRET)
# GLOBAL_SEC__vcap_services__cloudantNoSQLDB__0__credentials__url: $(params.tests__vcap_services__cloudantNoSQLDB__0__credentials__url)
# GLOBAL_SEC_log4js_logmet_logging_token: $(params.tests__log4js_logmet_logging_token)

# config 
export ENV_NEW_RELIC_APP_NAME=otc-cti-broker-ys1
# ENV_TIAM_URL: https://api.devops.dev.us-south.bluemix.net/v1/identity
