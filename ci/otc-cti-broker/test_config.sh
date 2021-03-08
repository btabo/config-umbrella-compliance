#!/usr/bin/env bash

# secrets
export OTC_API_BROKER_SECRET=$(get_env otc-cti-broker_OTC_API_SECRET)
unset test_tiam_secret

# config
unset CLOUDANT_URL
unset TIAM_URL
unset services__otc_api
unset services__otc_ui
unset test_tiam_id

# script file
export TESTS_SCRIPT_FILE=".jobs/nock.sh"