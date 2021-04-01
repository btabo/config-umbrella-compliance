#!/usr/bin/env bash

# secrets
export SEC_newrelic__insights_key="$(get_env otc-consumption_newrelic-insights-key)"
export SEC_newrelic__api_key="$(get_env otc-consumption_newrelic-apikey)"

# config 
export ENV_newrelic__account="'1783376"
export ENV_newrelic__alert_duration="1"
export ENV_newrelic__consumption_policy="387797"
export ENV_newrelic__interval="1"
export ENV_consumption__service_name="continuous-delivery"
export ENV_consumption__location_label="TIP_us-south"

# none