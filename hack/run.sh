#!/usr/bin/env bash

PROWJOB_NAME=periodic-ci-openshift-konflux-tasks-main-konflux-test-bundle

yq -o=json config.yaml > config.json
curl -d @config.json https://config.ci.openshift.org/resolve > resolved.json
GZIP_SPEC=$(gzip -c resolved.json | base64 -w0)
SPEC_FILE=$(mktemp)
cat <<EOF > "$SPEC_FILE"
{
  "job_name": "${PROWJOB_NAME}",
  "job_execution_type": 1,
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


curl -v -d "@${SPEC_FILE}" -H "Authorization: Bearer $TOKEN" https://gangway-ci.apps.ci.l2s4.p1.openshiftapps.com/v1/executions
