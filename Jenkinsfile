pipeline {
  environment {
      modName = credentials('RisingTidesModName')
      srcDir = credentials('RisingTidesSrcDir')
      sdkPath = credentials('SDKPath')
      gamePath = credentials('GamePath')
      PSPath = credentials('PowershellPath')
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
          echo %modName%
          echo %srcDir%
          echo %sdkPath%'
          echo %gamePath%
          echo %PSPath%
          echo ""
          echo ""
          %PSPath% set-executionpolicy remotesigned
          %PSPath% "./scripts/build_jenkins.ps1" -mod %modName% -srcDirectory "'%WORKSPACE%'" -sdkPath %sdkPath% -gamePath %gamePath%
        '''
      }
    }
  }
}
