#!/bin/bash
set -euo pipefail

export PATH="/usr/local/bin:/usr/bin:$PATH"

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${CHART_NAME:?CHART_NAME is required}"
: "${NEXT_VER:?NEXT_VER is required}"
: "${HARBOR_REGISTRY:?HARBOR_REGISTRY is required}"
: "${HARBOR_PROJECT:?HARBOR_PROJECT is required}"
: "${WORKSPACE:?WORKSPACE is required}"

PKG_FILE="${WORKSPACE}/chart-pkg/${CHART_NAME}-${NEXT_VER}.tgz"
RELEASE_TAG="${CHART_NAME}-v${NEXT_VER}"

if gh release view "${RELEASE_TAG}" >/dev/null 2>&1; then
  gh release upload "${RELEASE_TAG}" "${PKG_FILE}" --clobber
else
  gh release create "${RELEASE_TAG}" "${PKG_FILE}" \
    --title "${CHART_NAME} v${NEXT_VER}" \
    --notes "Release ${NEXT_VER} of ${CHART_NAME} pushed to oci://${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${CHART_NAME}:${NEXT_VER}"
fi