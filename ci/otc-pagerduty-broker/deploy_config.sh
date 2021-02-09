#!/usr/bin/env bash

CONFIG_FOLDER=$1

export NAMESPACE="opentoolchain"
export NUM_INSTANCES='1'
export RELEASE_NAME=$(cat $CONFIG_FOLDER/app-name)
export COMPONENT_NAME=$(cat $CONFIG_FOLDER/app-name)
export IMAGE_TAG= "latest"
export ROUTE=$(cat $CONFIG_FOLDER/app-name)
export DOMAIN="otc-dal12-test.us-south.containers.mybluemix.net"
export GLOBAL_ENV_SECGRP="GRP3DEVS"
export ENV_url="https://$COMPONENT_NAME.$DOMAIN"
#export PIPELINE_KUBERNETES_CLUSTER_NAME="otc-dal12-test"