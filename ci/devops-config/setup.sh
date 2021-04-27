#!/usr/bin/env bash

echo "The artifact is devops-config/environments, remove everything else"
echo find $WORKSPACE/devops-config/\* -maxdepth 0 -type d ! -name '.' ! -name '.git' ! -name '.secrets.baseline' ! -name 'environments' -exec rm -rf {} \\\;
find $WORKSPACE/devops-config/* -maxdepth 0 -type d ! -name '.' ! -name '.git' ! -name '.secrets.baseline' ! -name 'environments' -exec rm -rf {} \;
echo

echo ls -la $WORKSPACE/devops-config
ls -la $WORKSPACE/devops-config
