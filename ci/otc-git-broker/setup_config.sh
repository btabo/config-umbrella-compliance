INSTALL_BUILD_ESSENTIAL="true"
RUN_WEBPACK_BUILD="true"
############
export HOME=/root
. ~/.nvm/nvm.sh
npm --version
if [[ ! -f ~/.netrc ]]; then
    cat > ~/.netrc <<NETRC
machine github.ibm.com
login idsorg
password $IDSORG_TOKEN
NETRC
    chmod 600 ~/.netrc
fi
if [ "$INSTALL_BUILD_ESSENTIAL" ]; then
DEBIAN_FRONTEND=noninteractive apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential
fi

rm -r -f node_modules

echo -e "@otc-core:registry=https://na.artifactory.swg-devops.com/artifactory/api/npm/wcp-otc-core-team-npm-local/ \n_password=${ARTIFACTORY_TOKEN_BASE64} \nalways-auth=true \nemail=${ARTIFACTORY_ID} \nusername=${ARTIFACTORY_ID}\n@console:registry=https://na.artifactory.swg-devops.com/artifactory/api/npm/wcp-tmp-ace-fr-team-npm-virtual/ \n_password=${ARTIFACTORY_TOKEN_BASE64} \nalways-auth=true \nemail=${ARTIFACTORY_ID} \nusername=${ARTIFACTORY_ID}" > .npmrc
GIT_COMMIT=$(git log --format="%H" -n 1)
if [ "$RUN_WEBPACK_BUILD" ]; then
npm install
export NODE_ENV=production
npm run build && npm prune --production
else
echo "Running npm install --production"
npm install --production
fi

echo "$(get_env branch)-$(date +%Y%m%d%H%M%Z)-${GIT_COMMIT}" > .pipeline_build_id
echo "${GIT_COMMIT}-$(date +%Y%m%d%H%M%Z)" > .k8s_build_id
echo -e "{\"build\":\""$(date +%Y%m%d%H%M%S%Z)"\", \"appName\":\""${APP_NAME}"\", \"platform\":\""Armada"\", \"commit\":\""$GIT_COMMIT"\"}" > build.json
echo "Build id: $(cat .pipeline_build_id)"
