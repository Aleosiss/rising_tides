pipeline {
  environment {
      modName = "RisingTides"
  }

  options {
        timeout(time: 15, unit: 'MINUTES')
        disableConcurrentBuilds()
  }

  agent { 
    node { 
      label 'master'
      checkout([
         $class: 'GitSCM',
         branches: scm.branches,
         doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
         extensions: scm.extensions + [[$class: 'GitLFSPull']],
         userRemoteConfigs: scm.userRemoteConfigs
      ])
    } 
  }

  stages {
    stage('Build Mod Project') {
      steps {
        bat '''
          @echo "Building Mod Project!"
          @echo %WORKSPACE%
          @powershell set-executionpolicy remotesigned
          powershell "./scripts/build_jenkins.ps1" -mod %modName% -srcDirectory "'%WORKSPACE%'"
        '''
      }
    }

    stage('Upload Release') {
      when { branch 'feature/tagmaker' }
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-abatewongc-via-access-token', passwordVariable: 'personal_access_token', usernameVariable: 'username')]) {
          bat '''
            C:\\Python37\\python.exe scripts/tagmaker.py %personal_access_token% --repo rising_tides --current_commit_hash %GIT_COMMIT% --workspace_directory "%WORKSPACE%" --artifact_name %modName%.zip --should_increment 2
            '''
        }
      }
    }
  }
  
  post { 
        always { 
            deleteDir()
        }
    }
}