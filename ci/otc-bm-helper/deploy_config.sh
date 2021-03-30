#!/usr/bin/env bash

# secrets
export SEC_SESSION_SECRET=$(get_env otc-bm-helper_SESSION_SECRET)

# config 
export ENV_VCAP_APPLICATION='{"application_uris":["devops-dal12-test.us-south.containers.mybluemix.net"]}'

# none