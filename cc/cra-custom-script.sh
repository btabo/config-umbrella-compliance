#!/usr/bin/env bash
echo
echo "Doing cra setup"
ARTIFACTORY_API_KEY=$(cat /config/otc_ARTIFACTORY_API_KEY)
export ARTIFACTORY_API_KEY
DOCKERBUILDFLAGS="--build-arg ARTIFACTORY_API_KEY"
export DOCKERBUILDFLAGS
set_env cra-docker-build-context "true"
echo "cra setup done"

# workaround the fact that one cannot specify incident-labels per inventory entry for CRA in CC
# see https://ibm-cloudplatform.slack.com/archives/CFQHG5PP1/p1648649959554529
echo
currentDir=$(pwd)
repo=$(basename $currentDir)
inventoryEntry=$(load_repo $repo inventory-entry)
echo "set_env incident-labels \"squad:umbrella,$inventoryEntry\""
set_env incident-labels "squad:umbrella,$inventoryEntry"

# disable the use of .cracveomit or cra ignore file, so that CVEs are always tracked
# by the CC pipeline as issues
echo "[]" > .do-not-use-cveignore
set_env cra-cveignore-path "./.do-not-use-cveignore"