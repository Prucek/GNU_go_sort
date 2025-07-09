#!/usr/bin/env bash

KONFLUX_IMAGE="quay.io/prucek/multiop:bundle"

KONFLUX_TAG=$(echo "$KONFLUX_IMAGE" | cut -d':' -f2)
KONFLUX_RNN=$(echo "$KONFLUX_IMAGE" | cut -d':' -f1)
KONFLUX_NAME=$(echo "$KONFLUX_RNN" | rev | cut -d'/' -f1 | rev)
KONFLUX_NAMESPACE=$(echo "$KONFLUX_RNN" | rev | cut -d'/' -f2 | rev)
KONFLUX_REGISTRY=$(echo "$KONFLUX_RNN" | rev | cut -d'/' -f3- | rev)

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


CI_OPERATOR_CONFIG='
base_images:
  cli-operator-sdk:
    name: cli-operator-sdk
    namespace: ocp
    tag: v1.37.0
releases:
  latest:
    prerelease:
      product: ocp
      version_bounds:
        lower: 4.17.0-0
        upper: 4.18.0-0
        stream: 4-stable
      architecture: multi
resources:
  "*":
    requests:
      cpu: "1"
      memory: 1Gi
tests:
  - as: konflux-test-bundle
    cron: 0 0 1 1 0
    steps:
      cluster_profile: gcp
      dependencies:
        OO_BUNDLE: pipeline:konflux
      env:
        OCP_ARCH: arm64
        OO_INSTALL_NAMESPACE: openshift-multiarch-tuning-operator
      test:
        - as: konflux-test
          commands: "make e2e"
          from: root
          resources:
            requests:
              cpu: 100m
      workflow: optional-operators-ci-operator-sdk-gcp
'

echo "$CI_OPERATOR_CONFIG" > config.yaml
yq -i '(.build_root.project_image += {"dockerfile_literal": strenv(DOCKERFILE_LITERAL) })' config.yaml
yq -i '(.build_root.project_image += {"dockerfile_literal": strenv(DOCKERFILE_LITERAL) })' config.yaml
yq -i '(.external_images.konflux.registry = "'${KONFLUX_REGISTRY}'")' config.yaml
yq -i '(.external_images.konflux.namespace = "'${KONFLUX_NAMESPACE}'")' config.yaml
yq -i '(.external_images.konflux.name = "'${KONFLUX_NAME}'")' config.yaml
yq -i '(.external_images.konflux.tag = "'${KONFLUX_TAG}'")' config.yaml
yq -i '(.zz_generated_metadata.branch = "main")' config.yaml
yq -i '(.zz_generated_metadata.org = "openshift")' config.yaml
yq -i '(.zz_generated_metadata.repo = "konflux-tasks")' config.yaml

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
