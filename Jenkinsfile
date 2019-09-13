pipeline {
  environment {
      modName = "RisingTides"
  }

  options {
        timeout(time: 15, unit: 'MINUTES')
        disableConcurrentBuilds()
  }

  agent { node { label 'master' } }
  stages {
    stage('Code Checkout'){
      steps {
        checkout([$class: 'GitSCM',
        branches: [[name: '*/${BRANCH_NAME}']],
        doGenerateSubmoduleConfigurations: false,
        extensions: [], gitTool: 'Default',
        submoduleCfg: [],
        userRemoteConfigs: [[credentialsId: 'github-abatewongc-via-access-token',
        url: 'https://github.com/abatewongc/rising_tides/']]])
      }
    }

    stage('Build Mod Project') {
      steps {
        powershell label: '',
        script: '''
          echo "Building Mod Project!"
          echo %WORKSPACE%
          set-executionpolicy remotesigned
          "./scripts/build_jenkins.ps1" -mod %modName% -srcDirectory "\'%WORKSPACE%\'"
          '''
      }
    }

    stage('Upload Release') {
      when { branch 'feature/tagmaker' }
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-abatewongc-via-access-token', passwordVariable: 'personal_access_token', usernameVariable: 'username')]) {
          powershell label: '',
                    script: '''
                      python3 scripts/tagmaker.py %passwordVariable% --repo 'rising_tides' --current_commit_hash %COMMIT% --workspace_directory \%WORKSPACE\% --artifact
                      _name '\%modName\%.zip' --should_increment 0
                  '''
        }
      }
    }
  }
}
