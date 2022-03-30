#!/usr/bin/env bash

# Check compliance statuses. Return 1 if one of them is set and it is not "success"
# Return 0 if all statuses are success, or if EMERGENCY is set to true.
function checkComplianceStatuses() {
    while read -r stage; do
        local status=$(get_data result $stage)
        if [ "$status" ] && [ "$status" != "success" ]; then
            if [ "$(get_env EMERGENCY "")" == "true" ]; then
                echo "$stage result is $status. Ignoring since EMERGENCY == true."
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
    echo "Done installing cocoa cli"	
    echo	
}

# Install gh cli
function installGh() {
    local ghVersion='1.10.3'
    echo "Installing gh cli $ghVersion"
    curl -LO https://github.com/cli/cli/releases/download/v${ghVersion}/gh_${ghVersion}_linux_amd64.tar.gz
    tar xf gh_${ghVersion}_linux_amd64.tar.gz
    cp gh_${ghVersion}_linux_amd64/bin/gh /usr/local/bin/
    chmod +x /usr/local/bin/gh
    rm -rf gh_${ghVersion}_linux_amd64
    rm -f gh_${ghVersion}_linux_amd64.tar.gz
    echo "Done installing gh cli"	
    echo
}

# Clone otc-deploy and devops-config if needed
function cloneOtcDeploy() {
    local gitToken=$(get_env git-token)
    if [ ! -d "otc-deploy" ]; then
        echo git clone "https://$gitToken@github.ibm.com/org-ids/otc-deploy"
        git clone "https://$gitToken@github.ibm.com/org-ids/otc-deploy"
        local rc=$?
        if [ "$rc" != "0" ]; then
            exit $rc
        fi
        echo "Done"
        echo
    fi 
    if [ ! -d "devops-config" ]; then
        echo git clone "https://$gitToken@github.ibm.com/ids-env/devops-config"
        git clone "https://$gitToken@github.ibm.com/ids-env/devops-config"
        if [ "$rc" != "0" ]; then
            exit $rc
        fi
        echo "Done"
        echo
    fi 
}

# Remove otc-deploy, devos-config and otc-cf-deploy folders created by components
function cleanupOtcDeploy() {
    local root=${1:-$WORKSPACE/$REPO_FOLDER}
    echo "Cleaning up otc-deploy, devops-config, and otc-cf-deploy"
    if [ -d "$root/otc-deploy" ]; then
        echo rm -rf "$root/otc-deploy"
        rm -rf "$root/otc-deploy"
    fi
    if [ -d "$root/devops-config" ]; then
        echo rm -rf "$root/devops-config"
        rm -rf "$root/devops-config"
    fi
    if [ -d "$root/otc-cf-deploy" ]; then
        echo rm -rf "$root/otc-cf-deploy"
        rm -rf "$root/otc-cf-deploy"
    fi
    echo "Done"
    echo
    # echo ls -la $root
    # ls -la $root
    # echo
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

# Loop through all applications using the list_repos helper from one-pipeline
# and for each one, run the given command with the app-name, repository path and branch (as returned by load_repo) as arguments
function loopThroughApps() {
    local command=$1

    declare -A repos
    local repoList=$(list_repos)
    for repo in $repoList; do
        inventory_entry=$(load_repo "$repo" inventory-entry)
        repos[$inventory_entry]=$repo
    done

    local environment_branch=$(get_env "environment-branch" "")
    local artifacts=$(list_artifacts)
    for artifact in $artifacts; do
        local inventory_entry=$(load_artifact "$artifact" inventory-entry)
        local app_name=${inventory_entry}
        local repo=${repos[$inventory_entry]}
        local repo_path=$(load_repo "$repo" path)

        # cannot use $(load_repo "$repo" branch), see https://ibm-cloudplatform.slack.com/archives/CFQHG5PP1/p1648478879572919
        local branch
        if [ "$environment_branch" == "dev" ]; then
            branch="master"
        else
            branch="integration"
        fi

        echo "Processing $app_name"
        echo

        # add 2 labels on each incident found by the scans: "squad:umbrella" and "<app-name>"
        set_env incident-labels "squad:umbrella,$app_name" 
        
        echo "$command $app_name $repo_path $branch $artifact"
        $command "$app_name" "$repo_path" "$branch" "$artifact"
        echo "Done processing $app_name"
        echo
    done
}