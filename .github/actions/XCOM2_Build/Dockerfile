FROM ubuntu:18.04

LABEL "com.github.actions.name"         = "XCOM 2 WOTC SDK"
LABEL "com.github.actions.description"  = "Build an XCOM 2 WOTC mod project using the SDK."
LABEL "com.github.actions.icon"         = "check-square"
LABEL "com.github.actions.color"        = "blue"

LABEL "name"       = "github-action-xcom2sdk-builder"
LABEL "version"    = "1.0.0"
LABEL "maintainer" = "Christian Abate-Wong <abatewong@gmail.com>"

ADD entrypoint.ps1 /entrypoint.ps1

COPY LICENSE Readme.md /

ENTRYPOINT [ "pwsh", "/entrypoint.ps1" ]
