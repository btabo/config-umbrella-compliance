#!/usr/bin/env bash

CONFIG_FOLDER=${1:-"/config"}

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

# also .pipeline_build_id is needed by nock tests
echo $IMAGE_TAG > .pipeline_build_id