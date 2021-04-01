#!/usr/bin/env bash
if [[ "${PIPELINE_DEBUG:-0}" == 1 ]]; then
    trap env EXIT
    env | sort
    set -x
fi

REPO_FOLDER=$(load_repo app-repo path)
cd $WORKSPACE/$REPO_FOLDER

export APP_NAME=$(get_env app-name)

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

IMAGE_NAME="$(get_env app-name)"
IMAGE_TAG="$(get_env git-commit)-$(date +%Y%m%d%H%M%Z)" # need this exact format as it is used a BUILD_NUMBER passed to deployed app

BREAK_GLASS=$(get_env break_glass || true)

if [[ "$BREAK_GLASS" == "true" ]]; then
  ARTIFACTORY_URL="$(get_env artifactory | jq -r .parameters.repository_url)"
  ARTIFACTORY_REGISTRY="$(sed -E 's~https://(.*)/?~\1~' <<<"$ARTIFACTORY_URL")"
  ARTIFACTORY_INTEGRATION_ID="$(get_env artifactory | jq -r .instance_id)"
  IMAGE="$ARTIFACTORY_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
  jq -j --arg instance_id "$ARTIFACTORY_INTEGRATION_ID" '.services[] | select(.instance_id == $instance_id) | .parameters.token' /toolchain/toolchain.json | docker login -u "$(get_env artifactory | jq -r '.parameters.user_id')" --password-stdin "$(get_env artifactory | jq -r '.parameters.repository_url')"
else
  if [ "$(load_repo app-repo branch)" == "integration" ]; then
    ICR_REGISTRY_NAMESPACE="devopsotc"
  else
    ICR_REGISTRY_NAMESPACE="$(get_env registry-namespace)"
  fi
  ICR_REGISTRY_REGION="$(get-icr-region "$(get_env registry-region)")"
  IMAGE="$ICR_REGISTRY_REGION.icr.io/$ICR_REGISTRY_NAMESPACE/$IMAGE_NAME:$IMAGE_TAG"
  docker login -u iamapikey --password-stdin "$ICR_REGISTRY_REGION.icr.io" <<< $(get_env otc_IC_1416501_API_KEY)

  # Create the namespace if needed to ensure the push will be can be successfull
  echo "Checking registry namespace: ${ICR_REGISTRY_NAMESPACE}"
  IBM_LOGIN_REGISTRY_REGION=$(get_env registry-region | awk -F: '{print $3}')
  ibmcloud login --apikey $(get_env otc_IC_1416501_API_KEY) -r "$IBM_LOGIN_REGISTRY_REGION"
  NS=$( ibmcloud cr namespaces | sed 's/ *$//' | grep -x "${ICR_REGISTRY_NAMESPACE}" ||: )

  if [ -z "${NS}" ]; then
      echo "Registry namespace ${ICR_REGISTRY_NAMESPACE} not found"
      ibmcloud cr namespace-add "${ICR_REGISTRY_NAMESPACE}"
      echo "Registry namespace ${ICR_REGISTRY_NAMESPACE} created."
  else
      echo "Registry namespace ${ICR_REGISTRY_NAMESPACE} found."
  fi
fi

# Prevent the .git subdirectory to be copied in the Docker content
echo ".git/" >> .dockerignore
echo cat .dockerignore
cat .dockerignore

echo "Building image $IMAGE with arguments $DOCKER_BUILD_ARGS"
DOCKER_BUILD_ARGS="-t $IMAGE"
DOCKER_BUILDKIT=1 docker build $DOCKER_BUILD_ARGS .
docker push "$IMAGE"
echo "Done"
echo

echo "Saving image artifact..."
MANIFEST_SHA=$(docker inspect --format='{{index .RepoDigests 0}}' "$IMAGE" | awk -F@ '{print $2}')
echo "IMAGE=$IMAGE"
echo "MANIFEST_SHA=$MANIFEST_SHA"
echo "IMAGE_TAG=$IMAGE_TAG"
save_artifact service type=image \
  name="${IMAGE}" \
  digest="${MANIFEST_SHA}" \
  tags="${IMAGE_TAG}"
echo "Done"
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