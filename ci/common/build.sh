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