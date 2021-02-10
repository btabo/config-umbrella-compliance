#!/usr/bin/env bash
COMMON_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FOLDER=${1:-"/config"}

GIT_TOKEN=$(cat "$WORKSPACE/git-token")
if [ ! -d "otc-deploy" ]; then
  git clone "https://$GIT_TOKEN@github.ibm.com/org-ids/otc-deploy"
fi 
if [ ! -d "devops-config" ]; then
  git clone "https://$GIT_TOKEN@github.ibm.com/ids-env/devops-config"
fi 
APP_NAME=$(cat $CONFIG_FOLDER/app-name)
if [ -f "$COMMON_FOLDER/../$APP_NAME/deploy_config.sh" ]; then
    . $COMMON_FOLDER/../$APP_NAME/deploy_config.sh $CONFIG_FOLDER
fi
export IC_1308775_API_KEY=$(cat $CONFIG_FOLDER/IC_1308775_API_KEY)
. otc-deploy/k8s/scripts/login/clusterLogin.sh "otc-dal12-test"

####################################################
# Temporary Workarounds
# if helm > 2.15 is requiring now apiVersion in Chart.yml
#echo "apiVersion: 'v1'" >> k8s/$(params.componentName)/Chart.yaml
#cat k8s/$(params.componentName)/Chart.yaml
# Installing a specific helm version as the pipeline vbi seems not appropriate
echo "=========================================================="
echo "CHECKING HELM VERSION: matching Helm Tiller (server) if detected. "
set +e
LOCAL_VERSION=$( helm version --client ${HELM_TLS_OPTION} | grep SemVer: | sed "s/^.*SemVer:\"v\([0-9.]*\).*/\1/" )
TILLER_VERSION=$( helm version --server ${HELM_TLS_OPTION} | grep SemVer: | sed "s/^.*SemVer:\"v\([0-9.]*\).*/\1/" )
set -e
if [ -z "${TILLER_VERSION}" ]; then
  if [ -z "${HELM_VERSION}" ]; then
    CLIENT_VERSION=${LOCAL_VERSION}
  else
    CLIENT_VERSION=${HELM_VERSION}
  fi
else
  echo -e "Helm Tiller ${TILLER_VERSION} already installed in cluster. Keeping it, and aligning client."
  CLIENT_VERSION=${TILLER_VERSION}
fi
if [ "${CLIENT_VERSION}" != "${LOCAL_VERSION}" ]; then
  echo -e "Installing Helm client ${CLIENT_VERSION}"
  WORKING_DIR=$(pwd)
  mkdir ~/tmpbin && cd ~/tmpbin
  curl -L https://storage.googleapis.com/kubernetes-helm/helm-v${CLIENT_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && tar -xzvf helm.tar.gz
  cd linux-amd64
  export PATH=$(pwd):$PATH
  cd $WORKING_DIR
fi
####################################################

echo cat build.properties
cat build.properties
echo