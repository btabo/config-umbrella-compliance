#!/usr/bin/env bash

# secrets
# config 
# none

CLOUDANT_URL=$(get_env otc-git-broker_test-app-cloudant-url)
BITBUCKET_CLIENT_SECRET=$(get_env otc-git-broker_ta-bitbucket-client-secret)
DB_NAME=$(get_env otc-git-broker_db-name)
ENCRYPTER_PAYLOAD_CIPHER_KEY=$(get_env otc-git-broker_ta-encrypter-payload-cipher-key)
ENCRYPTER_PAYLOAD_HMAC_KEY=$(get_env otc-git-broker_ta-encrypter-payload-hmac-key)
GIT_SERVICE_SECRETS=$(get_env otc-git-broker_ta-git-service-secrets)
GITHUB_CLIENT_SECRET=$(get_env otc-git-broker_ta-github-client-secret)
GITLAB_CLIENT_SECRET=$(get_env otc-git-broker_ta-gitlab-client-secret)
GRIT_SECRET_TOKEN=$(get_env otc-git-broker_ta-grit-secret-token)
GRIT_SITE_ADMIN_TOKEN=$(get_env otc-git-broker_ta-grit-site-admin-token)
IAM_CLIENT_SECRET=$(get_env otc-git-broker_test-app-iam-client-secret)
UAA_CLIENT_SECRET=$(get_env otc-git-broker_ta-uaa-client-secret)
USER_ARRAY_API_KEY=$(get_env otc-git-broker_ta-userarray-api-key)

# cat > /artifacts/deploy-to-test-env << EOF
export GLOBAL_ENV_SECGRP="GRP3DEVS"
export GLOBAL_SEC__vcap_services__cloudantNoSQLDB__0__credentials__url="$CLOUDANT_URL"
export ENV_LOG4J_LEVEL='DEBUG'
export ENV_console_domain='dev.console.test.cloud.ibm.com'
export ENV_domain='.us-south.devops.dev.cloud.ibm.com'
export ENV_domain_expected_but='.otc-dal12-test.us-south.containers.mybluemix.net'
export ENV_encrypter__payload_encrypt='true'
export ENV_git__Bitbucket_0__services__bitbucketcustom__blacklist='[]'
export ENV_git__Bitbucket_0__services__bitbucketgit__clientId='KYfKDZA6D9X4Rum24T'
export ENV_git__Bitbucket_0__services__bitbucketgit__oauth_root='https://otc-github-consolidated-broker.otc-dal12-test.us-south.containers.mybluemix.net'
export ENV_git__GitHub_0__services__github__clientId='2f08fb111a98cb9470c8'
export ENV_git__GitHub_0__services__github__oauth_root='https://otc-github-consolidated-broker.otc-dal12-test.us-south.containers.mybluemix.net'
export ENV_git__GitHub_0__services__githubcustom__blacklist='[{"root_url": "https://github.dys0.bluemix.net"}]'
export ENV_git__GitLab_0__services__gitlab__clientId='fa571086699e247c700e6cd589b081fadab9711b8a4edf41b9fd7cbcf3956bd2'
export ENV_git__GitLab_0__services__gitlabcustom__blacklist='[{"root_url": "https://git.ng.bluemix.net"}]'
export ENV_git__GitLab_0__services__gitlabcustom__oauth_root='http://local.devops.stage1.ng.bluemix.net:5200'
export ENV_git__GitLab_1__services__hostedgit__title='Development'
export ENV_git_domain='us-south.git.dev.cloud.ibm.com'
export ENV_iam__client__id='otc'
export ENV_IAM_URL='https://iam.stage1.bluemix.net'
export ENV_redirect_whitelist='[".cloud.ibm.com", ".bluemix.net", "localhost:3000"]'
export ENV_services__env_id='ibm:ys1:us-south'
export ENV_uaa__client__id='otcclient'
export ENV_db_name="$DB_NAME"
export ENV_CLOUDANT_URL="$CLOUDANT_URL"
export ENV_CLOUDANT_IAM_CLIENT_ID_GIT="otc"
export ENV_CLOUDANT_IAM_API_KEY="$IAM_CLIENT_SECRET"
export ENV_url='https://otc-github-consolidated-broker.otc-dal12-test.us-south.containers.mybluemix.net'
export SEC_encrypter__payload_cipher_key="$ENCRYPTER_PAYLOAD_CIPHER_KEY"
export SEC_encrypter__payload_hmac_key="$ENCRYPTER_PAYLOAD_HMAC_KEY"
export SEC_git_service_secrets="$GIT_SERVICE_SECRETS"
export SEC_git__Bitbucket_0__services__bitbucketgit__clientSecret="$BITBUCKET_CLIENT_SECRET"
export SEC_git__GitHub_0__services__github__clientSecret="$GITHUB_CLIENT_SECRET"
export SEC_git__GitLab_0__services__gitlab__clientSecret="$GITLAB_CLIENT_SECRET"
export SEC_git__GitLab_1__services__hostedgit__secretToken="$GRIT_SECRET_TOKEN"
export SEC_git__GitLab_1__services__hostedgit__siteAdminToken="$GRIT_SITE_ADMIN_TOKEN"
export SEC_iam__client__secret="$IAM_CLIENT_SECRET"
export SEC_uaa__client__secret="$UAA_CLIENT_SECRET"
export SEC_userArray__0__api_key="$USER_ARRAY_API_KEY"
#EOF