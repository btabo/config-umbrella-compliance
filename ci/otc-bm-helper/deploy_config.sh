#!/usr/bin/env bash

# secrets
export SEC_SESSION_SECRET=$(get_env otc-bm-helper_SESSION_SECRET)
export SEC_OTC_TIAM_CLIENTS=$(get_env otc-bm-helper_OTC_TIAM_CLIENTS)

# config 
export ENV_VCAP_APPLICATION='{"application_uris":["devops-dal12-test.us-south.containers.mybluemix.net"]}'

# none
# To ensure the deployment to test is successful in order to use vault entry
# export EXTRA=$(cat <<'EOT'
# use_vault: true
# vault:
#   secretPaths:
#   - generic/crn/v1/bluemix/public/continuous-delivery/au-syd/otc-components/common-iam_do_not_version
#   - generic/crn/v1/bluemix/public/continuous-delivery/au-syd/otc-components/common-tiam-client_do_not_version    
# EOT
# )
