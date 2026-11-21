#!/bin/bash
set -euo pipefail

: "${HARBOR_REGISTRY:?HARBOR_REGISTRY is required}"
: "${HARBOR_PROJECT:?HARBOR_PROJECT is required}"
: "${HARBOR_USER:?HARBOR_USER is required}"
: "${HARBOR_PASS:?HARBOR_PASS is required}"
: "${CHART_NAME:?CHART_NAME is required}"
: "${NEXT_VER:?NEXT_VER is required}"
: "${WORKSPACE:?WORKSPACE is required}"
: "${INSECURE_TLS:=false}"

LOGIN_OPTS=""
if [ "${INSECURE_TLS}" = "true" ]; then
  LOGIN_OPTS="--insecure"
fi

echo "${HARBOR_PASS}" | helm registry login "${HARBOR_REGISTRY}" \
  -u "${HARBOR_USER}" \
  --password-stdin \
  ${LOGIN_OPTS}

helm push "${WORKSPACE}/chart-pkg/${CHART_NAME}-${NEXT_VER}.tgz" \
  "oci://${HARBOR_REGISTRY}/${HARBOR_PROJECT}"