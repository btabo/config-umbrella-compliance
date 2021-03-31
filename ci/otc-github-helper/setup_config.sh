export HOME=/root
if [[ ! -f ~/.netrc ]]; then
    cat > ~/.netrc <<NETRC
machine github.ibm.com
login idsorg
password $IDS_TOKEN
NETRC
    chmod 600 ~/.netrc
fi

export GIT_REF="$(git rev-parse --abbrev-ref HEAD)"
export BUILD_GIT_COMMIT="$(git rev-parse $GIT_REF)"
export BUILD_DATE="$(date +%Y%m%d%H%M%Z)"
export BUILD_PLATFORM="Armada"
export BUILD_APP_NAME="otc-github-helper"
export BUILD_VERSION="$BUILD_GIT_COMMIT-$BUILD_DATE"
echo "- Setting build version to $BUILD_DATE"
echo "- Setting build platform to $BUILD_PLATFORM"
echo "- Setting commit to $BUILD_GIT_COMMIT"
echo "- Setting appName to $BUILD_APP_NAME"
sed "s/\${BUILD_ID}/$BUILD_DATE/g; s/\${BUILD_PLATFORM}/$BUILD_PLATFORM/g; s/\${BUILD_APP_NAME}/$BUILD_APP_NAME/g; s/\${BUILD_COMMIT_ID}/$BUILD_GIT_COMMIT/g" src/main/resources/otc-github-helper.properties.template > src/main/resources/otc-github-helper.properties
echo "$BUILD_VERSION" > build.version
echo "- Building using Git commit:"
git log -1
echo "- Building application"
mvn -B package
echo "$(get_env branch)-$(date +%Y%m%d%H%M%Z)-$BUILD_GIT_COMMIT" > .pipeline_build_id
echo "$BUILD_GIT_COMMIT-$(date +%Y%m%d%H%M%Z)" > .k8s_build_id
echo -e "{\"build\":\""$(date +%Y%m%d%H%M%Z)"\", \"appName\":\""otc-github-helper"\", \"platform\":\""Armada"\", \"commit\":\""$BUILD_GIT_COMMIT"\"}" > build.json
