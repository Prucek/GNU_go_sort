#!/usr/bin/env bash

KONFLUX_IMAGE="quay.io/prucek/multiop:bundle"
PROWJOB_NAME="periodic-ci-openshift-multiarch-tuning-operator-main-ocp418-e2e-aws-ovn-proxy-mto-origin"
VARIANT="ocp418"
IMAGE_IN_CONFIG="multiarch-tuning-operator"
ORG=openshift
REPO=multiarch-tuning-operator
COMMIT=main
TARGET_BRANCH=main
DRY_RUN=0
ARTIFACTS_BUILD_ROOT=quay-proxy.ci.openshift.org/openshift/ci:ocp_builder_rhel-9-golang-1.23-openshift-4.19
INCLUDE_IMAGES=1
INCLUDE_OPERATOR=1
ENVS=""

TAG=$(echo "$KONFLUX_IMAGE" | cut -d':' -f2)
RNN=$(echo "$KONFLUX_IMAGE" | cut -d':' -f1)
NAME=$(echo "$RNN" | rev | cut -d'/' -f1 | rev)
NAMESPACE=$(echo "$RNN" | rev | cut -d'/' -f2 | rev)
REGISTRY=$(echo "$RNN" | rev | cut -d'/' -f3- | rev)

DOCKERFILE_ADDITIONS=$(cat <<EOF
RUN make build 
EOF
)

DOCKERFILE_LITERAL=$(cat <<EOF
FROM ${ARTIFACTS_BUILD_ROOT}
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

if [[ -z "$VARIANT" ]]; then
  CI_OPERATOR_CONFIG=$(curl -sSL https://raw.githubusercontent.com/openshift/release/master/ci-operator/config/${ORG}/${REPO}/"${ORG}-${REPO}-${TARGET_BRANCH}.yaml")
else
  CI_OPERATOR_CONFIG=$(curl -sSL https://raw.githubusercontent.com/openshift/release/master/ci-operator/config/${ORG}/${REPO}/"${ORG}-${REPO}-${TARGET_BRANCH}__${VARIANT}.yaml")
fi

 # Modifying ci-op config
echo "$CI_OPERATOR_CONFIG" > config.yaml
yq -i 'del(.build_root.project_image)' config.yaml
yq -i 'del(.build_root.from_repository)' config.yaml
if [[ "$INCLUDE_IMAGES" == "0" ]]; then
  yq -i 'del(.images)' config.yaml
fi
if [[ "$INCLUDE_OPERATOR" == "0" ]]; then
  yq -i 'del(.operator)' config.yaml
fi
yq -i '(.build_root.project_image += {"dockerfile_literal": strenv(DOCKERFILE_LITERAL) })' config.yaml
yq -i '(.external_images."'${IMAGE_IN_CONFIG}'".registry = "'${REGISTRY}'")' config.yaml
yq -i '(.external_images."'${IMAGE_IN_CONFIG}'".namespace = "'${NAMESPACE}'")' config.yaml
yq -i '(.external_images."'${IMAGE_IN_CONFIG}'".name = "'${NAME}'")' config.yaml
yq -i '(.external_images."'${IMAGE_IN_CONFIG}'".tag = "'${TAG}'")' config.yaml

 # env var modifications
if [[ -n "$ENVS" ]]; then
  IFS=',' read -ra PAIRS <<< "$ENVS"
  for pair in "${PAIRS[@]}"; do
    KEY=$(echo "$pair" | cut -d'=' -f1)
    VALUE=$(echo "$pair" | cut -d'=' -f2-)
    yq -i '.tests[].steps.env."'"${KEY}"'" = "'"${VALUE}"'"' config.yaml
  done
fi


yq -o=json config.yaml | jq -Rs . > config.json
payload=$(jq -n --arg job "$PROWJOB_NAME" --arg org "$ORG" --arg repo "$REPO" \
  --argjson config "$(cat config.json)" \
  '{
      "job_name": $job,
      "job_execution_type": "1",
      "pod_spec_options": {
        "annotations": {
          "ci.openshift.io/konflux-repo" : ($org + "/" + $repo),
        },
        "envs": {
          "UNRESOLVED_CONFIG": $config
        },
        }
    }')

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "DRY RUN - not submitting the job"
  echo "$payload"
  exit 0
fi
NAMESPACE="konflux-tp"
SECRET_NAME="api-token-secret-2025-04"
# Extract token from the secret
TOKEN=$(oc --context app.ci -n "$NAMESPACE" extract "secret/$SECRET_NAME" --to=- --keys=token)
curl -v -d "$payload" -H "Authorization: Bearer $TOKEN" https://gangway-ci.apps.ci.l2s4.p1.openshiftapps.com/v1/executions
