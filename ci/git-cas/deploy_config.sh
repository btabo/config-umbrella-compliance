#!/usr/bin/env bash

# secrets
export SEC_iam__client_secret="$SEC_CLOUDANT_IAM_API_KEY"

# config 
export GLOBAL_SEC__vcap_services__cloudantNoSQLDB__0__credentials__url="$ENV_CLOUDANT_URL"
export ENV_iam__info_url="https://iam.test.cloud.ibm.com/identity/.well-known/openid-configuration"
export ENV_iam__client_id="cd_grit"
export ENV_auth_mode="iam"
export ENV_service_whitelist__0="https://github.stage1.ng.bluemix.net"
export ENV_service_whitelist__1="https://git.stage1.ng.bluemix.net"
export ENV_service_whitelist__2="https://gitlab01-ys1-dev-01.stage1.ng.bluemix.net"
export ENV_service_whitelist__3="https://gitlab01-ys1-dev-02.stage1.ng.bluemix.net"
export ENV_db_name="git-cas-integration"
export ENV_CLOUDANT_IAM_CLIENT_ID_GIT="cd-cloudant-git"
export ENV_normalization__strategy="legacy-short"

# none