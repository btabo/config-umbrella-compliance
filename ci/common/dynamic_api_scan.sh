#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

export APP_NAME=$1
REPO_FOLDER=$2
BRANCH=$3
ARTIFACT=$4

COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $COMMON_FOLDER/../../helpers.sh

if [ -z $BRANCH ]; then
    BRANCH=$(load_repo app-repo branch)
fi

function ciDynamicApiScan() {
    DYNAMIC_API_SCAN_BRANCH=$(get_env "dynamic-api-scan-branch" "")
    if [ "$DYNAMIC_API_SCAN_BRANCH" != "$BRANCH" ]; then
        echo "Skipping ZAP dynamic API scan since dynamic-api-scan-branch is set to $DYNAMIC_API_SCAN_BRANCH"
        echo
        return 0
    fi

    if [ -z $APP_NAME ]; then
        export APP_NAME=$(get_env app-name)
    fi
    if [ -f $COMMON_FOLDER/../$APP_NAME/dynamic_api_scan.sh ]; then
        source $COMMON_FOLDER/../$APP_NAME/dynamic_api_scan.sh
        return $?
    fi

    if [ -z $REPO_FOLDER ]; then
        REPO_FOLDER=$(load_repo app-repo path)
    fi
    cd $WORKSPACE

    # secrets and config specific to the component
    if [ -f "$COMMON_FOLDER/../$APP_NAME/dynamic_api_scan_config.sh" ]; then
        . $COMMON_FOLDER/../$APP_NAME/dynamic_api_scan_config.sh
    fi

    if [ -z "$SWAGGER_DEFINITION_FILE" ]; then
        echo "Skipping ZAP dynamic API scan since SWAGGER_DEFINITION_FILE is not set"
        echo
        return 0
    fi

    # run scan

    # Configure API scan. These can be set either directly in the pipeline as environment properties, or directly in
    # your script as shown below.

    # - swagger-definition-files (required): A comma-separated list of workspace-relative paths to swagger files describing your API to scan,
    #     e.g. "your-app/spec/swagger1.json,your-app/spec/swagger2.yml". JSON and YAML are supported, both Swagger 2.0 and OpenAPI.
    set_env swagger-definition-files "$REPO_FOLDER/${SWAGGER_DEFINITION_FILE}"
    # - target-api-key (optional): Required for endpoints that use IAM bearer authentication. The IAM API key the scanner should use to get a
    #     IAM bearer token to authenticate with the endpoints. This should be a functional scan/test user's API key, not a privileged user like
    #     idsorg. If none provided then the scanner will not send an Authorization header.
    set_env target-api-key "$(get_env otc_SWAGGER_API_KEY)"
    # - target-application-server-url (optional): Base url of the app to scan, e.g. "https://devops-api.devops.dev.cloud.ibm.com" if not provided,
    #     defaults to a URL to the host or server specified in the first swagger file listed in swagger-definition-files.
    if [ "$BRANCH" == "integration" ]; then
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
    # - zap-artifact (optional): The artifact (string) that is scanned and that will get results associated with (using save_result and save_artifact)
    if [ $ARTIFACT ]; then
        set_env zap-artifact $ARTIFACT
    fi

    # clone otc-deploy if needed
    cloneOtcDeploy

    # run scan
    echo "Running ZAP dynamic API scan for ${APP_NAME}..."
    . otc-deploy/k8s/scripts/zap/run_api_scan.sh
    echo "Done running ZAP dynamic API scan for ${APP_NAME}"
    echo
    cleanupOtcDeploy $WORKSPACE
}

ciDynamicApiScan