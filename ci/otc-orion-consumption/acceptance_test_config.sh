#!/usr/bin/env bash

# secrets

# config
# Use the /version endpoint to ensure the service is up & running
export TEST_URL="https://otc-orion-server-consumption-$NAMESPACE.$DOMAIN/version"

# script file
export ACCEPTANCE_TESTS_SCRIPT_FILE=""