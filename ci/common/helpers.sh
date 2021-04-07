#!/usr/bin/env bash

# Check statuses. Return 1 if one of them is not "success"
function checkStatuses() {
    # uses undocumented env vars as workaround for https://github.ibm.com/one-pipeline/adoption-issues/issues/254
    local allStatusVars="STAGE_TEST_STATUS CRA_VULNERABILITY_RESULTS_STATUS CIS_CHECK_VULNERABILITY_RESULTS_STATUS CRA_BOM_CHECK_RESULTS_STATUS BRANCH_PROTECTION_STATUS STAGE_SCAN_ARTIFACT_STATUS STAGE_SIGN_ARTIFACT_STATUS STAGE_ACCEPTANCE_TEST_STATUS"
    for statusVar in $allStatusVars; do
        if [ "${!statusVar}" != "success" ]; then
            echo "$statusVar=${!statusVar}"
            return 1
        fi
    done
    return 0
}

# Install cocoa cli
function installCocoa() {
    local cocoaVersion=1.5.0
    echo "Installing cocoa cli $cocoaVersion"
    curl -u ${ARTIFACTORY_ID}:${ARTIFACTORY_API_KEY} -O "https://eu.artifactory.swg-devops.com/artifactory/wcp-compliance-automation-team-generic-local/cocoa-linux-${cocoaVersion}"
    cp cocoa-linux-* /usr/local/bin/cocoa
    chmod +x /usr/local/bin/cocoa
    export PATH="$PATH:/usr/local/bin/"
    echo "Done"
    echo
}