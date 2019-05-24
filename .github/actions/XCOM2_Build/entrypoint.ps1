[cmdletbinding()]
Param(
    [string]$mod
)

$sdkPath = "C:/SteamLibrary/steamapps/common/XCOM 2 War of the Chosen SDK"

ls

pwsh -file "$env:GITHUB_WORKSPACE/scripts/build_docker.ps1" -mod "$mod" -srcDirectory "$env:GITHUB_WORKSPACE" -sdkPath "$sdkPath"