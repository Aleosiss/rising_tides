FROM microsoft/windowsservercore:1803

ENV STEAMCMD_PATH="C:\\steamcmd\\"
ENV STEAMCMD="${STEAMCMD_PATH}\\steamcmd.exe"
ENV USERNAME="cicd_x2mod"
ENV PASSWORD="luxray1234sw"
ENV LIBPATH="C:\\SteamLibrary\\"

SHELL ["powershell"]
RUN \
Invoke-WebRequest "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile "C:\\steamcmd.zip" -UseBasicParsing;\
Expand-Archive "C:\\steamcmd.zip" -DestinationPath $env:STEAMCMD_PATH

SHELL [ "cmd", "/S", "/C" ]
RUN powershell $(c:\steamcmd\steamcmd.exe +login anonymous +quit; powershell exit 0)

RUN \
#$env:STEAMCMD +login $env:USERNAME $env:PASSWORD \
c:\steamcmd\steamcmd +login stormhunter117 luxray1234sw \
#+force_install_dir $env:LIBPATH \
+force_install_dir c:\SteamLibrary \
+app_update 602410 \
+quit ; \
exit 0

SHELL ["powershell"]
RUN \
#Start-Process msiexec.exe -Wait -ArgumentList '\\I ${LIBPATH}\\steamapps\\common\\XCOM 2 War of the Chosen SDK\\binaries\\redist\\vs_isoshell.exe \\norestart \\q' ;\
Start-Process msiexec.exe -Wait -ArgumentList '\\I ${LIBPATH}\\steamapps\\common\\XCOM 2 War of the Chosen SDK\\binaries\\redist\\ue3redist.exe -progressonly'

ENV LOCAL_SRCORIG="C:\\Program Files (x86)\\Steam\\steamapps\\common\\XCOM 2 War of the Chosen SDK\\Development\\SrcOrig"
ENV REMOTE_SRCORIG="${LIBPATH}\\steamapps\\common\\XCOM 2 War of the Chosen SDK\\Development\\SrcOrig\\"

# copy in highlander files
COPY "${LOCAL_SRCORIG}\\*" "${REMOTE_SRCORIG}"

ENTRYPOINT ["powershell"]