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

  stage('Build Mod Project') {
    bat 'echo %WORKSPACE%'
    bat '%PSPath% "./scripts/build.ps1" -mod %modName% -srcDirectory %WORKSPACE% -sdkPath %sdkPath% -gamePath %gamePath%'
  }
}
