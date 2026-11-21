pipeline {
  agent { label 'control-plane' }

  triggers {
    githubPush()
  }

  environment {
    GIT_REPO_URL    = 'git@github.com:Raj34970/pki-helm.git'
    GIT_BRANCH      = 'main'
    CHART_SUBDIR    = ''
    HARBOR_REGISTRY = 'harbor.lxhome.fr'
    HARBOR_PROJECT  = 'lxhome'
    HARBOR_CREDS_ID = 'harbor-creds'
    GITHUB_TOKEN_ID = 'github-token'
    INSECURE_TLS    = 'false'
    SRC_DIR         = "${WORKSPACE}/repo-src"
  }

  stages {
    stage('Git Pull to Temp Directory') {
      steps {
        sh '''
          set -euo pipefail
          rm -rf "${SRC_DIR}"
          git clone --depth 1 --branch "${GIT_BRANCH}" "${GIT_REPO_URL}" "${SRC_DIR}"
          git -C "${SRC_DIR}" pull --ff-only origin "${GIT_BRANCH}"
          ls -la "${SRC_DIR}"
        '''
      }
    }

    stage('Detect Previous Release & Compute Next Version') {
      steps {
        withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDS_ID}", usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
          script {
            def chartDir = env.CHART_SUBDIR?.trim() ? "${env.SRC_DIR}/${env.CHART_SUBDIR.trim()}" : "${env.SRC_DIR}"

            def releaseInfo = sh(
              script: "CHART_DIR='${chartDir}' /home/jenkins/scripts/detect_version.sh",
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
        script {
          def chartDir = env.CHART_SUBDIR?.trim() ? "${env.SRC_DIR}/${env.CHART_SUBDIR.trim()}" : "${env.SRC_DIR}"
          sh "CHART_DIR='${chartDir}' /home/jenkins/scripts/package_chart.sh"
        }
      }
    }

    stage('Push Chart to Harbor OCI') {
      steps {
        withCredentials([usernamePassword(credentialsId: "${HARBOR_CREDS_ID}", usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
          sh '/home/jenkins/scripts/push_harbor.sh'
        }
      }
    }

    stage('Create GitHub Release') {
      steps {
        withCredentials([string(credentialsId: "${GITHUB_TOKEN_ID}", variable: 'GH_TOKEN')]) {
          sh "cd '${SRC_DIR}' && /home/jenkins/scripts/create_gh_release.sh"
        }
      }
    }
  }

  post {
    always {
      sh "rm -rf '${SRC_DIR}' '${WORKSPACE}/chart-pkg' || true"
    }
  }
}