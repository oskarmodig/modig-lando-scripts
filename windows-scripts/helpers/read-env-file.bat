@echo off
setlocal enabledelayedexpansion
REM Define a temporary file
set tempFile=%temp%\modigLandoScriptEnvVars.bat
:readEnvFile
    REM Check for parameter
    if [%~1] == [] (
        echo No file was passed to readEnvFile function
        goto:eof
    )
    set "filename=%~1"
    REM Read env files
    if exist "!filename!" (
        echo Reading env file: !filename!
        >> "%tempFile%" (
            for /F "delims== tokens=1,* eol=#" %%i in (!filename!) do (
                echo set "%%i=%%~j"
            )
        )
    ) else (
        echo File !filename! does not exist
    )
goto:eof
