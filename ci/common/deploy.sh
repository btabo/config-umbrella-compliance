#!/usr/bin/env bash

echo "BUILD_NUMBER=$BUILD_NUMBER"
echo cat build.properties
cat build.properties
echo
. otc-deploy/k8s/scripts/deployComponentToCluster.sh
