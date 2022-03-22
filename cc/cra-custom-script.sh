#!/usr/bin/env bash
echo "Doing cra setup"
ARTIFACTORY_API_KEY=$(cat /config/otc_ARTIFACTORY_API_KEY)
export ARTIFACTORY_API_KEY
DOCKERBUILDFLAGS="--build-arg ARTIFACTORY_API_KEY"
export DOCKERBUILDFLAGS
set_env cra-docker-build-context "true"
echo "cra setup done"
