FROM microsoft/windowsservercore:1803

ENV STEAMCMD_PATH="C:\\steamcmd\\"
ENV STEAMCMD="${STEAMCMD_PATH}\\steamcmd.exe"
ENV USERNAME=""
ENV PASSWORD=""
ENV LIBPATH="C:\\SteamLibrary\\"

SHELL ["powershell"]
RUN \
Invoke-WebRequest "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile "$env:TEMP\steamcmd.zip" -UseBasicParsing;\
[System.IO.Compression.ZipFile]::ExtractToDirectory("C:\\steamcmd.zip", ${STEAMCMD_PATH})

RUN & \
'${STEAMCMD}' login ${USERNAME} ${PASSWORD}; \
force_install_dir ${LIBPATH}} ; \
app_update 602410 ;

RUN \
Start-Process msiexec.exe -Wait -ArgumentList '/I ${LIBPATH}\\steamapps\\common\\XCOM 2 War of the Chosen SDK\\binaries\\redist\\vs_isoshell.exe /norestart /q' ;\
Start-Process msiexec.exe -Wait -ArgumentList '/I ${LIBPATH}\\steamapps\\common\\XCOM 2 War of the Chosen SDK\\binaries\\redist\\ue3redist.exe -progressonly'

ENV LOCAL_SRCORIG=""
ENV REMOTE_SRCORIG="${LIBPATH}\\steamapps\\common\\XCOM 2 War of the Chosen SDK\\Development\\SrcOrig\\"

# copy in highlander files
COPY "${LOCAL_SRCORIG}\\*" "${REMOTE_SRCORIG}"

ENTRYPOINT ["powershell"]