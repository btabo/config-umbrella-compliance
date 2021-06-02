#!/usr/bin/env bash

# Check compliance statuses. Return 1 if one of them is set and it is not "success"
# Return 0 if all statuses are success, or if EMERGENCY is set to true.
function checkComplianceStatuses() {
    while read -r stage; do
        local status=$(get_data result $stage)
        if [ "$status" ] && [ "$status" != "success" ]; then
            if [ "$(get_env EMERGENCY "")" == "true" ]; then
                echo "$statusVar=$status. Ignoring since EMERGENCY == true."
                echo
                return 0
            else
                echo "$stage result is $status"
                return 1
            fi
        fi
    done < <(get_data result)
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

# Detect changes in devops-config between the 2 given commits for the given environment.
# Return true if it is an umbrella related change and the inventory branch should be updated.
# Return false if no inventory entry should be updated.
function detectDevopsConfigChange() {
    local result=$1
    local env=$2
    local toCommit=$3
    local inventoryOrg=$4
    local inventoryRepo=$5

    # Get previous commit from inventory
    echo "Getting previous commit from inventory"
    local expected=( 200 )
    local curlGetArgs="-X GET -s -u :$GHE_TOKEN https://raw.github.ibm.com/$inventoryOrg/$inventoryRepo/$env/config"
    curlCli hide $GHE_TOKEN getResult "$curlGetArgs" expected
    local fromCommit=$(echo "$getResult"  | jq -r '.commit_sha')
    echo "Done"
    echo

    echo "Detecting config changes between $fromCommit and $toCommit in $env"
    echo
    local hasChanges="false"
    local allChanges=$( git diff --name-only $fromCommit $toCommit | grep "environments/" ) # Get list of files that changed (this includes relative paths)
    if [ "$allChanges" ]; then
        local envChanges=""
        local chartRepo=""
        if [ "$env" == "dev" ]; then
            envChanges=$( echo "$allChanges" | grep "/dev/" )
            chartRepo="devops-dev"
        else
            envChanges=$( echo "$allChanges" | grep -v "/dev/" ) # check staging and prod changes (everything that is not dev)
            chartRepo="devops-int"
        fi
        if [ "$envChanges" ]; then
            hasChangesForUmbrellaComponents hasChanges "$envChanges" $chartRepo $fromCommit $toCommit
        fi
    fi 
    if [ "$hasChanges" == "true" ]; then
        echo "Config changes detected in $env"
    else
        echo "No config changes detected in $env"
    fi
    echo

    eval "$result=$hasChanges"
}