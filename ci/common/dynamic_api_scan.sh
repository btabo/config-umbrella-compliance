#!/usr/bin/env bash

BRANCH=$(load_repo app-repo branch)
DYNAMIC_API_SCAN_BRANCH=$(get_env "dynamic-api-scan-branch" "")
if [ "$DYNAMIC_API_SCAN_BRANCH" != "$BRANCH" ]; then
    echo "Skipping dynamic scan since dynamic-api-scan-branch is set to $DYNAMIC_API_SCAN_BRANCH"
    echo
    exit 0
fi

if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export APP_NAME=$(get_env app-name)
if [ -f $COMMON_FOLDER/../$APP_NAME/dynamic_api_scan.sh ]; then
    source $COMMON_FOLDER/../$APP_NAME/dynamic_api_scan.sh
    exit $?
fi

source $COMMON_FOLDER/helpers.sh
REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE

# secrets and config specific to the component
if [ -f "$COMMON_FOLDER/../$APP_NAME/dynamic_api_scan_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/dynamic_api_scan_config.sh
fi

# run tests
if [ "$SWAGGER_DEFINITION_FILE" ]; then
    # Configure API scan. These can be set either directly in the pipeline as environment properties, or directly in
    # your script as shown below.

    # - ibmcloud-api-key (required): An IAM API key for idsorg@us.ibm.com for the 1651315 - bmdevops.dev account. This is temporary and is used
    #     to pull the ZAP scanner image until the images are made public.
    set_env ibmcloud-api-key $(get_env otc_IC_1651315_API_KEY)
    # - swagger-definition-files (required): A comma-separated list of workspace-relative paths to swagger files describing your API to scan,
    #     e.g. "your-app/spec/swagger1.json,your-app/spec/swagger2.yml". JSON and YAML are supported, both Swagger 2.0 and OpenAPI.
    set_env swagger-definition-files "$REPO_FOLDER/${SWAGGER_DEFINITION_FILE}"
    # - target-api-key (optional): Required for endpoints that use IAM bearer authentication. The IAM API key the scanner should use to get a
    #     IAM bearer token to authenticate with the endpoints. This should be a functional scan/test user's API key, not a privileged user like
    #     idsorg. If none provided then the scanner will not send an Authorization header.
    set_env target-api-key "$(get_env otc_SWAGGER_API_KEY)"
    # - target-application-server-url (optional): Base url of the app to scan, e.g. "https://devops-api.devops.dev.cloud.ibm.com" if not provided,
    #     defaults to a URL to the host or server specified in the first swagger file listed in swagger-definition-files.
    if [ "$(load_repo app-repo branch)" == "integration" ]; then
        export NAMESPACE="otc-int"
    else
        export NAMESPACE="opentoolchain"
    fi
    if [ -z $ROUTE ]; then
        SUBDOMAIN=$APP_NAME-$NAMESPACE
    else 
        SUBDOMAIN=$ROUTE-$NAMESPACE
    fi
    export DOMAIN="otc-dal10-test-ebc4c2329856a2fac5ef9072561d9bbf-0000.us-south.containers.appdomain.cloud"
    set_env target-application-server-url "https://$SUBDOMAIN.$DOMAIN"

    # clone otc-deploy if needed
    cloneOtcDeploy

    # run scan
    echo "Running ZAP dynamic API scan for ${APP_NAME}..."
    . otc-deploy/k8s/scripts/zap/run_api_scan.sh
    echo "Done running ZAP dynamic API scan for ${APP_NAME}"
    echo
    cleanupOtcDeploy $WORKSPACE
else
    echo "Skipping ZAP dynamic API scan since SWAGGER_DEFINITION_FILE is not set"
    echo
fi
