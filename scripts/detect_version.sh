#!/bin/bash
set -euo pipefail

: "${CHART_DIR:?CHART_DIR is required}"
: "${HARBOR_REGISTRY:?HARBOR_REGISTRY is required}"
: "${HARBOR_PROJECT:?HARBOR_PROJECT is required}"
: "${HARBOR_USER:?HARBOR_USER is required}"
: "${HARBOR_PASS:?HARBOR_PASS is required}"
: "${INSECURE_TLS:=false}"

CHART_NAME=$(awk '/^name:/ {print $2; exit}' "${CHART_DIR}/Chart.yaml")
BASE_VERSION=$(awk '/^version:/ {print $2; exit}' "${CHART_DIR}/Chart.yaml")

CURL_OPTS="-fsS -u ${HARBOR_USER}:${HARBOR_PASS}"
if [ "${INSECURE_TLS}" = "true" ]; then
  CURL_OPTS="${CURL_OPTS} -k"
fi

API_URL="https://${HARBOR_REGISTRY}/api/v2.0/projects/${HARBOR_PROJECT}/repositories/${CHART_NAME}/artifacts?page_size=100"
LATEST_TAG=$(curl ${CURL_OPTS} "${API_URL}" 2>/dev/null \
  | grep -oE '"name":"[0-9]+\.[0-9]+\.[0-9]+"' \
  | sed -E 's/"name":"([^"]+)"/\1/' \
  | sort -V \
  | tail -n 1 || true)

PREV_VER="${LATEST_TAG:-$BASE_VERSION}"
IFS='.' read -r MAJOR MINOR PATCH <<< "${PREV_VER}"
NEXT_PATCH=$((PATCH + 1))
NEXT_VER="${MAJOR}.${MINOR}.${NEXT_PATCH}"

echo "CHART_NAME=${CHART_NAME}"
echo "PREV_VER=${PREV_VER}"
echo "NEXT_VER=${NEXT_VER}"