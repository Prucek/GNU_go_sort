#!/usr/bin/env bash

OPENSHIFT_VERSION="4.17.22"
export OPENSHIFT_VERSION
CHANNEL_STREAM="4-stable"
export CHANNEL_STREAM
ARCHITECTURE="arm64"
CLOUD_PROVIDER="gcp"
ENVS="OO_PACKAGE=stable,OO_CHANNEL=foo,OO_INSTALL_MODE=bar"

#OPERATOR IMAGE KONFLUX_IMAGE="quay.io/redhat-user-workloads/multiarch-tuning-ope-tenant/multiarch-tuning-operator/multiarch-tuning-operator@sha256:9220d65fc6d0df44f58300baeab9792b0fca8c1b9ad6fdd7be92fbf7672a04e6"
#BUNDLE IMAGE
KONFLUX_IMAGE="quay.io/redhat-user-workloads/multiarch-tuning-ope-tenant/multiarch-tuning-operator/multiarch-tuning-operator-bundle@sha256:981b8fe5df2f3e4a46bf1a11dde8361f9cfc6a8d9f45dd27b4650ae1dea65677"
# BUNDLE_NS="openshift-multiarch-tuning-operator"
CATALOG_NS="openshift-multiarch-tuning-operator"

KONFLUX_TAG=$(echo "$KONFLUX_IMAGE" | cut -d':' -f2)
KONFLUX_RNN=$(echo "$KONFLUX_IMAGE" | cut -d':' -f1)
KONFLUX_NAME=$(echo "$KONFLUX_RNN" | rev | cut -d'/' -f1 | rev)
KONFLUX_NAMESPACE=$(echo "$KONFLUX_RNN" | rev | cut -d'/' -f2 | rev)
KONFLUX_REGISTRY=$(echo "$KONFLUX_RNN" | rev | cut -d'/' -f3- | rev)

#operator
#DEPLOY_TEST_COMMAND='"CLEANUP=true USE_OLM=false ./hack/deploy-and-e2e.sh"'
#bundle
DEPLOY_TEST_COMMAND='"make e2e"'

DOCKERFILE_ADDITIONS=$(cat <<EOF
RUN make build 
EOF
)
ORG=openshift
REPO=multiarch-tuning-operator
COMMIT=main
BUILD_ROOT=quay-proxy.ci.openshift.org/openshift/ci:ocp_builder_rhel-9-golang-1.23-openshift-4.19

DOCKERFILE_LITERAL=$(cat <<EOF
FROM ${BUILD_ROOT}
COPY --from=quay-proxy.ci.openshift.org/openshift/ci:ocp_4.18_cli /bin/oc /bin/oc
COPY --from=quay-proxy.ci.openshift.org/openshift/ci:ocp_4.18_cli /bin/kubectl /bin/kubectl
RUN umask 0002
WORKDIR /workspace
RUN curl -L -o repo.zip "https://github.com/${ORG}/${REPO}/archive/${COMMIT}.zip" && unzip repo.zip
WORKDIR /workspace/${REPO}-${COMMIT}
${DOCKERFILE_ADDITIONS}
RUN find /workspace -type d -not -perm -0777 | xargs --max-procs 10 --max-args 100 --no-run-if-empty chmod 777
RUN find /workspace -type f -not -perm -0777 | xargs --max-procs 10 --max-args 100 --no-run-if-empty chmod 777
RUN find /go -type d -not -perm -0777 | xargs --max-procs 10 --max-args 100 --no-run-if-empty chmod 777
RUN find /go -type f -not -perm -0777 | xargs --max-procs 10 --max-args 100 --no-run-if-empty chmod 777
EOF
)
export DOCKERFILE_LITERAL

EXEC_TYPE=1


curl https://raw.githubusercontent.com/openshift/release/refs/heads/master/ci-operator/config/openshift/konflux-tasks/openshift-konflux-tasks-main.yaml > config.yaml
yq -i 'del(.build_root.project_image)' config.yaml
yq -i 'del(.tests[].steps.test[].cli)' config.yaml
yq -i '(.build_root.project_image += {"dockerfile_literal": strenv(DOCKERFILE_LITERAL) })' config.yaml
yq -i '(.external_images.konflux.registry = "'${KONFLUX_REGISTRY}'")' config.yaml
yq -i '(.external_images.konflux.namespace = "'${KONFLUX_NAMESPACE}'")' config.yaml
yq -i '(.external_images.konflux.name = "'${KONFLUX_NAME}'")' config.yaml
yq -i '(.external_images.konflux.tag = "'${KONFLUX_TAG}'")' config.yaml
if [[ -n "$PULL_SECRET" ]]; then
  yq -i '(.external_images.konflux.pull_secret = "'${PULL_SECRET}'")' config.yaml
fi

#Release
if [[ $CHANNEL_STREAM == "stable" || $CHANNEL_STREAM == "fast" || $CHANNEL_STREAM == "candidate" ]]; then
  yq -i '(.releases.latest.release.channel = "'${CHANNEL_STREAM}'")' config.yaml
  yq -i '(.releases.latest.release.version = "'${OPENSHIFT_VERSION}'")' config.yaml
  yq -i '(.releases.latest.release.architecture = "amd64")' config.yaml
elif [[ $CHANNEL_STREAM == "4-stable" ]]; then
  minor=$(echo "$OPENSHIFT_VERSION" | cut -d. -f2)
  minor_plus_one=$((minor + 1))
  yq -i '(.releases.latest.prerelease.product = "ocp" )' config.yaml
  yq -i '(.releases.latest.prerelease.version_bounds.lower = "4.'${minor}'.0-0")' config.yaml
  yq -i '(.releases.latest.prerelease.version_bounds.upper = "4.'${minor_plus_one}'.0-0")' config.yaml
  yq -i '(.releases.latest.prerelease.version_bounds.stream = "'${CHANNEL_STREAM}'")' config.yaml
  yq -i 'del( .releases.latest.release)' config.yaml
elif [[ $CHANNEL_STREAM == "nightly" || $CHANNEL_STREAM == "konflux-nightly" || $CHANNEL_STREAM == "ci" ]]; then
  yq -i '(.releases.latest.candidate.product = "ocp" )' config.yaml
  yq -i '(.releases.latest.candidate.architecture = "amd64")' config.yaml
  yq -i '(.releases.latest.candidate.stream = "'${CHANNEL_STREAM}'")' config.yaml
  yq -i '(.releases.latest.candidate.version = "'${OPENSHIFT_VERSION}'")' config.yaml
  yq -i 'del( .releases.latest.release)' config.yaml
else
  echo "❌ Error: Invalid channel/stream specified. Use one of stable, fast, candidate, 4-stable, nightly, konflux-nightly, ci."
  exit 1
fi

sed -i "s|operator-placeholder|pipeline:konflux|g" config.yaml
sed -i "s|operator-placeholder|pipeline:konflux|g" config.yaml
sed -i "s|command-placeholder|$DEPLOY_TEST_COMMAND|g" config.yaml

if [[ $ARCHITECTURE == "arm64" ]]; then
  yq -i '(.releases.latest.*.architecture = "multi")' config.yaml
  sed -i "s|amd64|arm64|g" config.yaml
fi

 # env var modifications
if [[ -n "$ENVS" ]]; then
  IFS=',' read -ra PAIRS <<< "$ENVS"
  for pair in "${PAIRS[@]}"; do
    KEY=$(echo "$pair" | cut -d'=' -f1)
    VALUE=$(echo "$pair" | cut -d'=' -f2-)
    yq -i '.tests[].steps.env."'"${KEY}"'" = "'"${VALUE}"'"' config.yaml
  done
fi

update_config() {
  ns=$1
  test_type=$2
  sed -i "s|ns-placeholder|$ns|g" config.yaml
  sed -i "s|optional-operators-ci-operator-sdk-aws|optional-operators-ci-operator-sdk-$CLOUD_PROVIDER|g" config.yaml
  sed -i "s|optional-operators-ci-aws|optional-operators-ci-$CLOUD_PROVIDER|g" config.yaml
  cluster_profile=$(yq '( .tests[] | select(.as == "*'${CLOUD_PROVIDER}'*") |.steps.cluster_profile )' config.yaml)
  sed -i "s|cluster_profile: aws|cluster_profile: $cluster_profile|g" config.yaml
  yq -i 'del( .tests[] | select(.as != "*'"${test_type}"'*") )' config.yaml
}

if [[ $BUNDLE_NS != "" ]]; then
  PROWJOB_NAME="periodic-ci-openshift-konflux-tasks-main-konflux-test-bundle"
  update_config "$BUNDLE_NS" "bundle"
elif [[ $CATALOG_NS != "" ]]; then
  PROWJOB_NAME="periodic-ci-openshift-konflux-tasks-main-konflux-test-catalog"
  update_config "$CATALOG_NS" "catalog"
elif [[ $CLOUD_PROVIDER == "gcp" ]]; then
  PROWJOB_NAME="periodic-ci-openshift-konflux-tasks-main-konflux-test-gcp"
  yq -i 'del( .tests[] | select(.as != "*gcp*") )' config.yaml
elif [[ $CLOUD_PROVIDER == "azure" ]]; then
  PROWJOB_NAME="periodic-ci-openshift-konflux-tasks-main-konflux-test-azure"
  yq -i 'del( .tests[] | select(.as != "*azure*") )' config.yaml
else
  PROWJOB_NAME="periodic-ci-openshift-konflux-tasks-main-konflux-test-aws"
  yq -i 'del( .tests[] | select(.as != "*aws*") )' config.yaml
fi

#BUNDLE_PRE_TEST_COMMAND="oc apply -k ./deploy/envs/prow-konflux-bundle"
export BUNDLE_PRE_TEST_COMMAND
# Pre-test command
if [[ -n "$BUNDLE_PRE_TEST_COMMAND" ]]; then
  yq -i '.tests[0].steps.pre =  [ {"chain": "ipi-"+"'${CLOUD_PROVIDER}'"+"-pre"} ]' config.yaml
  yq -i '.tests[0].steps.pre += [ .tests[].steps.test[0] ]' config.yaml
  yq -i '.tests[0].steps.pre[1].as = "konflux-pre"' config.yaml
  yq -i '.tests[0].steps.pre[1].commands = env(BUNDLE_PRE_TEST_COMMAND)' config.yaml
  yq -i '.tests[0].steps.pre += [ {"ref": "optional-operators-operator-sdk"} ]' config.yaml
fi

yq -o=json config.yaml > config.json
curl -d @config.json https://config.ci.openshift.org/resolve > resolved.json
GZIP_SPEC=$(gzip -c resolved.json | base64 -w0)
SPEC_FILE=$(mktemp)
cat <<EOF > "$SPEC_FILE"
{
  "job_name": "${PROWJOB_NAME}",
  "job_execution_type": "${EXEC_TYPE}",
  "pod_spec_options": {
    "envs": {
      "CONFIG_SPEC": "${GZIP_SPEC}",
    },
    "annotations": {
      "creator": "konflux"
    }
  }
}
EOF

echo "SPEC_FILE: $(cat $SPEC_FILE)"
