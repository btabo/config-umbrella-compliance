#!/usr/bin/env bash

echo "BUILD_NUMBER=$BUILD_NUMBER"
. otc-deploy/k8s/scripts/deployComponentToCluster.sh
