#!/usr/bin/env bash

# secrets
export OTC_API_BROKER_SECRET=$(get_env otc-cti-broker_OTC_API_SECRET)       

# config
# none

# script file
export TESTS_SCRIPT_FILE=".jobs/nock.sh"