#!/usr/bin/env bash

# Check compliance statuses. Return 1 if one of them is set and it is not "success"
function checkComplianceStatuses() {
    # uses undocumented env vars as workaround for https://github.ibm.com/one-pipeline/adoption-issues/issues/254
    local allStatusVars="STAGE_TEST_STATUS CRA_VULNERABILITY_RESULTS_STATUS CIS_CHECK_VULNERABILITY_RESULTS_STATUS CRA_BOM_CHECK_RESULTS_STATUS BRANCH_PROTECTION_STATUS STAGE_SCAN_ARTIFACT_STATUS STAGE_SIGN_ARTIFACT_STATUS STAGE_ACCEPTANCE_TEST_STATUS"
    for statusVar in $allStatusVars; do
        local status=${!statusVar}
        if [ "$status" ] && [ "$status" != "success" ]; then
            echo "$statusVar=$status"
            return 1
        fi
    done
    return 0
}

# Install cocoa cli	
function installCocoa() {	
    local cocoaVersion=1.7.1	
    echo "Installing cocoa cli $cocoaVersion"	
    curl -u ${ARTIFACTORY_ID}:${ARTIFACTORY_API_KEY} -O "https://eu.artifactory.swg-devops.com/artifactory/wcp-compliance-automation-team-generic-local/cocoa-linux-${cocoaVersion}"	
    cp cocoa-linux-* /usr/local/bin/cocoa	
    chmod +x /usr/local/bin/cocoa	
    export PATH="$PATH:/usr/local/bin/"	
    echo "Done"	
    echo	
}

# Clone otc-deploy and devops-config if needed
function cloneOtcDeploy() {
    local gitToken=$(get_env git-token)
    if [ ! -d "otc-deploy" ]; then
        git clone "https://$gitToken@github.ibm.com/org-ids/otc-deploy"
        echo "Done"
        echo
    fi 
    if [ ! -d "devops-config" ]; then
        git clone "https://$gitToken@github.ibm.com/ids-env/devops-config"
        echo "Done"
        echo
    fi 
}

# Remove otc-deploy, devos-config and otc-cf-deploy folders created by components
function cleanupOtcDeploy() {
    echo "Cleaning up otc-deploy, devops-config, and otc-cf-deploy"
    if [ -d "$WORKSPACE/$REPO_FOLDER/otc-deploy" ]; then
        echo rm -rf "$WORKSPACE/$REPO_FOLDER/otc-deploy"
        rm -rf "$WORKSPACE/$REPO_FOLDER/otc-deploy"
    fi
    if [ -d "$WORKSPACE/$REPO_FOLDER/devops-config" ]; then
        echo rm -rf "$WORKSPACE/$REPO_FOLDER/devops-config"
        rm -rf "$WORKSPACE/$REPO_FOLDER/devops-config"
    fi
    if [ -d "$WORKSPACE/$REPO_FOLDER/otc-cf-deploy" ]; then
        echo rm -rf "$WORKSPACE/$REPO_FOLDER/otc-cf-deploy"
        rm -rf "$WORKSPACE/$REPO_FOLDER/otc-cf-deploy"
    fi
    echo "Done"
    echo
    echo ls -la $WORKSPACE/$REPO_FOLDER
    ls -la $WORKSPACE/$REPO_FOLDER
    echo
}

# Process changes in devops-config from previous commit to given commit
# and if it is an umbrella related change, return the inventory branches that should be updated (dev and/or staging)
# or none if no inventory entry should be added.
function processDevopsConfigChange() {
    local result=$1
    local toCommit=$2

    local fromCommit=$(git rev-parse $toCommit^)

    echo "Processing config changes between $fromCommit and $toCommit"
    echo

    # Get list of files that changed (this includes relative paths)
    local inventoryBranches=""
    local allChanges=$( git diff --name-only $fromCommit $toCommit | grep "environments/" )
    if [ "$allChanges" ]; then
        # check dev changes
        local devChanges=$( echo "$allChanges" | grep "/dev/" )
        if [ "$devChanges" ]; then
            local hasChanges
            hasChangesForUmbrellaComponents hasChanges "$devChanges" devops-dev $fromCommit $toCommit
            if [ "$hasChanges" == "true" ]; then
                echo "Changes detected in dev"
                inventoryBranches="dev $inventoryBranches"
            fi
        fi

        # check staging and prod changes (everything that is not dev)
        local stagingCHanges=$( echo "$allChanges" | grep -v "/dev/" ) 
        if [ "$stagingCHanges" ]; then
            local hasChanges
            hasChangesForUmbrellaComponents hasChanges "$stagingCHanges" devops-int $fromCommit $toCommit
            if [ "$hasChanges" == "true" ]; then
                echo "Changes detected in staging/prod"
                inventoryBranches="staging $inventoryBranches"
            fi
        fi

        if [ "$inventoryBranches" ]; then
            echo "Done processing config changes"
        else
            echo "No config changes detected"
        fi
    else
        echo "No config changes detected"
    fi 
    echo

    printf -v inventoryBranches '%q' "$inventoryBranches"
    eval "$result=$inventoryBranches"
}