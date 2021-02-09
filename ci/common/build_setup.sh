#!/usr/bin/env bash

CONFIG_FOLDER=${1:-"/config"}

if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
  set -x
  trap env EXIT
fi

get-icr-region() {
  case "$1" in
    ibm:yp:us-south)
      echo us
      ;;
    ibm:yp:eu-de)
      echo de
      ;;
    ibm:yp:eu-gb)
      echo uk
      ;;
    ibm:yp:jp-tok)
      echo jp
      ;;
    ibm:yp:au-syd)
      echo au
      ;;
    *)
      echo "Unknown region: $1" >&2
      exit 1
      ;;
  esac
}

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update && apt-get install docker-ce-cli

IMAGE_NAME="$(cat $CONFIG_FOLDER/app-name)"
IMAGE_TAG="$(date +%Y%m%d%H%M%S)-$(cat $CONFIG_FOLDER/git-branch)-$(cat $CONFIG_FOLDER/git-commit)"

BREAK_GLASS=$(cat $CONFIG_FOLDER/break_glass || true)

if [[ "$BREAK_GLASS" == "true" ]]; then
  ARTIFACTORY_URL="$(jq -r .parameters.repository_url $CONFIG_FOLDER/artifactory)"
  ARTIFACTORY_REGISTRY="$(sed -E 's~https://(.*)/?~\1~' <<<"$ARTIFACTORY_URL")"
  ARTIFACTORY_INTEGRATION_ID="$(jq -r .instance_id $CONFIG_FOLDER/artifactory)"
  IMAGE="$ARTIFACTORY_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
  jq -j --arg instance_id "$ARTIFACTORY_INTEGRATION_ID" '.services[] | select(.instance_id == $instance_id) | .parameters.token' /toolchain/toolchain.json | docker login -u "$(jq -r '.parameters.user_id' $CONFIG_FOLDER/artifactory)" --password-stdin "$(jq -r '.parameters.repository_url' $CONFIG_FOLDER/artifactory)"
else
  ICR_REGISTRY_NAMESPACE="$(cat $CONFIG_FOLDER/registry-namespace)"
  ICR_REGISTRY_REGION="$(get-icr-region "$(cat $CONFIG_FOLDER/registry-region)")"
  IMAGE="$ICR_REGISTRY_REGION.icr.io/$ICR_REGISTRY_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG"
  docker login -u iamapikey --password-stdin "$ICR_REGISTRY_REGION.icr.io" < $CONFIG_FOLDER/IC_1416501_API_KEY

  # Create the namespace if needed to ensure the push will be can be successfull
  echo "Checking registry namespace: ${ICR_REGISTRY_NAMESPACE}"
  IBM_LOGIN_REGISTRY_REGION=$(cat $CONFIG_FOLDER/registry-region | awk -F: '{print $3}')
  ibmcloud login --apikey @$CONFIG_FOLDER/IC_1416501_API_KEY -r "$IBM_LOGIN_REGISTRY_REGION"
  NS=$( ibmcloud cr namespaces | sed 's/ *$//' | grep -x "${ICR_REGISTRY_NAMESPACE}" ||: )

  if [ -z "${NS}" ]; then
      echo "Registry namespace ${ICR_REGISTRY_NAMESPACE} not found"
      ibmcloud cr namespace-add "${ICR_REGISTRY_NAMESPACE}"
      echo "Registry namespace ${ICR_REGISTRY_NAMESPACE} created."
  else
      echo "Registry namespace ${ICR_REGISTRY_NAMESPACE} found."
  fi
fi

DOCKER_BUILD_ARGS="-t $IMAGE"
