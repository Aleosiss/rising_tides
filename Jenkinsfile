node('master') {

  stage('Code Checkout'){
    checkout([$class: 'GitSCM',
    branches: [[name: '*/nightly']],
    doGenerateSubmoduleConfigurations: false,
    extensions: [], gitTool: 'Default',
    submoduleCfg: [],
    userRemoteConfigs: [[credentialsId: 'github-abatewongc-via-access-token',
    url: 'https://github.com/abatewongc/rising_tides/']]])
  }

  environment {
    modName: credentials('RisingTidesModName')
    srcDir: credentials('RisingTidesSrcDir')
    sdkPath: credentials('SDKPath')
    gamePath: credentials('GamePath')
    PSPath: credentials('PowershellPath')
  }  
  
  withCredentials ([  [$class: 'StringBinding', credentialsId: 'RisingTidesModName', variable: 'modName'], 
                      [$class: 'StringBinding', credentialsId: 'RisingTidesSrcDir', variable: 'srcDir'],
                      [$class: 'StringBinding', credentialsId: 'SDKPath', variable: 'sdkPath'],
                      [$class: 'StringBinding', credentialsId: 'GamePath', variable: 'gamePath'],
                      [$class: 'StringBinding', credentialsId: 'PowershellPath', variable: 'PSPath']]) {
  stage('Build Mod Project') {
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
      %PSPath% "./scripts/build.ps1" -mod %modName% -srcDirectory %WORKSPACE% -sdkPath %sdkPath% -gamePath %gamePath%
      '''
    }
  }
}
