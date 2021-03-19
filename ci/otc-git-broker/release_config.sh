#!/usr/bin/env bash

# to pass helm lint --strict
export GLOBAL_ENV_SECGRP="topasshelmlintanddryrun"
export GLOBAL_SEC__vcap_services__cloudantNoSQLDB__0__credentials__url="topasshelmlintanddryrun"
export ENV_url="topasshelmlintanddryrun"
export ENV_domain="topasshelmlintanddryrun"
export ENV_services__env_id="topasshelmlintanddryrun"
