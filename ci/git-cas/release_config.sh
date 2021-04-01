#!/usr/bin/env bash

# to pass helm lint --strict
export GLOBAL_ENV_SECGRP="topasshelmlintanddryrun"
export ENV_db_name="topasshelmlintanddryrun"
export GLOBAL_SEC__vcap_services__cloudantNoSQLDB__0__credentials__url="topasshelmlintanddryrun"
export ENV_normalization__strategy="topasshelmlintanddryrun"
