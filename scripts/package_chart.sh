#!/bin/bash
set -euo pipefail

: "${CHART_DIR:?CHART_DIR is required}"
: "${CHART_NAME:?CHART_NAME is required}"
: "${NEXT_VER:?NEXT_VER is required}"
: "${WORKSPACE:?WORKSPACE is required}"

PKG_DIR="${WORKSPACE}/chart-pkg"
rm -rf "${PKG_DIR}"
mkdir -p "${PKG_DIR}"

helm lint "${CHART_DIR}"
helm dependency build "${CHART_DIR}"
helm package "${CHART_DIR}" --version "${NEXT_VER}" --destination "${PKG_DIR}"
ls -lh "${PKG_DIR}/${CHART_NAME}-${NEXT_VER}.tgz"