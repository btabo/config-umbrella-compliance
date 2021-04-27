#!/usr/bin/env bash

# since we're not using otc-deploy image any longer, need to install scripts manually
echo "Copying otc-deploy scripts"
cp -r otc-deploy/k8s/scripts/* /
cp -r devops-config/otc-deploy/* /otc-config
echo "Done"
echo

source ./cd/acceptance_test.sh
