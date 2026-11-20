pipeline {
  agent any

  environment {
    CHART_DIR       = 'lxhome/pki'
    HARBOR_REGISTRY = 'harbor.lxhome.fr'
    HARBOR_PROJECT  = 'lxhome'
    HARBOR_CREDS_ID = 'harbor-creds'
    INSECURE_TLS    = 'false'
  }

  stages {
    stage('Detect Previous Release & Compute Next Version') {
      steps {
        withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDS_ID}", usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
          script {
            def releaseInfo = sh(
              script: '''
                set -euo pipefail
                CHART_NAME=$(awk '/^name:/ {print $2; exit}' "${CHART_DIR}/Chart.yaml")
                BASE_VERSION=$(awk '/^version:/ {print $2; exit}' "${CHART_DIR}/Chart.yaml")

                CURL_OPTS="-fsS -u ${HARBOR_USER}:${HARBOR_PASS}"
                if [ "${INSECURE_TLS}" = "true" ]; then
                  CURL_OPTS="${CURL_OPTS} -k"
                fi

                API_URL="https://${HARBOR_REGISTRY}/api/v2.0/projects/${HARBOR_PROJECT}/repositories/${CHART_NAME}/artifacts?page_size=100"
                LATEST_TAG=$(curl ${CURL_OPTS} "${API_URL}" 2>/dev/null \
                  | grep -oE '"name":"[0-9]+\.[0-9]+\.[0-9]+"' \
                  | sed -E 's/"name":"([^"]+)"/\\1/' \
                  | sort -V \
                  | tail -n 1 || true)

                PREV_VER="${LATEST_TAG:-$BASE_VERSION}"
                IFS='.' read -r MAJOR MINOR PATCH <<< "${PREV_VER}"
                NEXT_PATCH=$((PATCH + 1))
                NEXT_VER="${MAJOR}.${MINOR}.${NEXT_PATCH}"

                echo "CHART_NAME=${CHART_NAME}"
                echo "PREV_VER=${PREV_VER}"
                echo "NEXT_VER=${NEXT_VER}"
              ''',
              returnStdout: true
            ).trim()

            def props = [:]
            releaseInfo.split('\n').each { line ->
              def idx = line.indexOf('=')
              if (idx > 0) {
                props[line.substring(0, idx).trim()] = line.substring(idx + 1).trim()
              }
            }

            env.CHART_NAME = props.CHART_NAME
            env.PREV_VER   = props.PREV_VER
            env.NEXT_VER   = props.NEXT_VER

            echo "Detected previous version: ${env.PREV_VER} -> Packaging next version: ${env.NEXT_VER}"
          }
        }
      }
    }

    stage('Lint, Build Dependencies & Package Chart') {
      steps {
        sh '''
          set -euo pipefail
          rm -rf "${WORKSPACE}/chart-pkg"
          mkdir -p "${WORKSPACE}/chart-pkg"

          helm lint "${CHART_DIR}"
          helm dependency build "${CHART_DIR}"
          helm package "${CHART_DIR}" --version "${NEXT_VER}" --destination "${WORKSPACE}/chart-pkg"
          ls -lh "${WORKSPACE}/chart-pkg/${CHART_NAME}-${NEXT_VER}.tgz"
        '''
      }
    }

    stage('Push Chart to Harbor OCI') {
      steps {
        withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDS_ID}", usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
          sh '''
            set -euo pipefail
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
          '''
        }
      }
    }
  }

  post {
    always {
      sh "rm -rf '${WORKSPACE}/chart-pkg' || true"
    }
  }
}