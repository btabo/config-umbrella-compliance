#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env
    set -x
fi

CONFIG_FOLDER=${1:-"/config"}
export APP_NAME=$(cat $CONFIG_FOLDER/app-name)
cd $APP_NAME

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
IMAGE_TAG="$(cat $CONFIG_FOLDER/git-commit)-$(date +%Y%m%d%H%M%Z)" # need this exact format as it is used a BUILD_NUMBER passed to deployed app

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
DOCKER_BUILDKIT=1 docker build $DOCKER_BUILD_ARGS .
docker push "$IMAGE"

echo -n $(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE" | awk -F@ '{print $2}') > ../../image-digest
echo -n "$IMAGE_TAG" > ../../image-tags
echo -n "$IMAGE" > ../../image

echo cat ../../image-digest
cat ../../image-digest
echo
echo cat ../../image-tags
cat ../../image-tags
echo
echo cat ../../image
cat ../../image
echo

# pass image information along via build.properties
echo "IMAGE_REGISTRY=$ICR_REGISTRY_REGION.icr.io" >> build.properties
echo "REGISTRY_NAMESPACE=${ICR_REGISTRY_NAMESPACE}" >> build.properties
echo "IMAGE_NAME=${IMAGE_NAME}" >> build.properties
echo "REGISTRY_URL=$ICR_REGISTRY_REGION.icr.io/${ICR_REGISTRY_NAMESPACE}" >> build.properties
echo "APPLICATION_VERSION=$IMAGE_TAG" >> build.properties
echo "BUILD_NUMBER=${BUILD_NUMBER}" >> build.properties

echo cat build.properties
cat build.properties
echo

# also .pipeline_build_id is needed by acceptance tests
echo $IMAGE_TAG > .pipeline_build_id