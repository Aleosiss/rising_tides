Param(
    [string]$gamePath # the path to your XCOM 2 installation ending in "XCOM 2"
)

Start-Process -FilePath "$gamePath/Binaries/Win64/Launcher/StartDebugging.bat" -Wait -NoNewWindow -WorkingDirectory "$gamePath/Binaries/Win64/Launcher"
