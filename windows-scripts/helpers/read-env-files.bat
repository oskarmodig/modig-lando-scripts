@echo off
setlocal enabledelayedexpansion

REM Function starts here
:readEnvFile
    REM Check for parameter
    if [%~1] == [] (
        echo No file was passed to readEnvFile function
    ) else (
        set "filename=%~1"

        REM Read env files
        if exist !filename! (
            echo Reading env file: !filename!
            for /F "delims== tokens=1,* eol=#" %%i in (!filename!) do set %%i=%%~j
        ) else (
            echo File !filename! does not exist
        )
    )

    REM Clear the filename
    set "filename="
goto:eof
