#!/usr/bin/env bash

# secrets

# config
export TEST_URL="https://otc-github-consolidated-broker-$NAMESPACE.$DOMAIN/status"
if [ "$NAMESPACE" == "otc-int" ]; then
    export SKIP_HEALTH_CHECK="true"
fi

# script file
export ACCEPTANCE_TESTS_SCRIPT_FILE=""