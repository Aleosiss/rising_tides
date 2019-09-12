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
        bat '''
          echo "Building Mod Project!"
          echo %WORKSPACE%
          echo ""
          echo ""
          powershell set-executionpolicy remotesigned
          powershell "./scripts/build_jenkins.ps1" -mod %modName% -srcDirectory "'%WORKSPACE%'"
        '''
      }
    }

    stage('Upload Release') {
      steps {
        bat '''
          echo "Doing nothing for now!"
        '''
      }
    }
  }
}
