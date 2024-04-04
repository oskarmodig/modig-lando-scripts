@echo off
:: Inspired by
:: https://hackernoon.com/lando-wordpress-and-ngrokoh-my
setlocal enabledelayedexpansion

where /q ngrok
IF ERRORLEVEL 1 (
    echo ngrok is not installed.
    echo Visit https://ngrok.com/download and download the version for your OS.
    goto:EOF
)
where /q jq
IF ERRORLEVEL 1 (
    echo jq is not installed.
    echo Visit https://stedolan.github.io/jq/download/ and download the version for your OS.
    echo If you have one, you can usually use your package manager to install it.
    goto:EOF
)

if not defined MODIG_NGROK_FULL_LOCAL_URL (
    :: Get the https url from lando
    FOR /F "usebackq tokens=*" %%a IN (`lando info --format json ^| jq ".[0].urls[3]"`) DO SET MODIG_NGROK_FULL_LOCAL_URL=%%~a
)
:: Extract the protocol (http or https)
for /f "tokens=1 delims=:" %%a in ("!MODIG_NGROK_FULL_LOCAL_URL!") do set PROTOCOL=%%a

:: Check if the URL contains a port
echo.!MODIG_NGROK_FULL_LOCAL_URL! | findstr /R /C:":.*:" >nul
if errorlevel 1 (

    :: Remove any trailing slash
    IF "!MODIG_NGROK_FULL_LOCAL_URL:~-1!"=="/" (
        REM If it is, then remove the last character
        SET "MODIG_NGROK_FULL_LOCAL_URL=!MODIG_NGROK_FULL_LOCAL_URL:~0,-1!"
    )

    :: No port found, decide which port to add based on the protocol
    if "!PROTOCOL!"=="http" (
        set MODIG_NGROK_FULL_LOCAL_URL=!MODIG_NGROK_FULL_LOCAL_URL!:80
    ) else if "!PROTOCOL!"=="https" (
        set MODIG_NGROK_FULL_LOCAL_URL=!MODIG_NGROK_FULL_LOCAL_URL!:443
    )
)

:: Remove the protocol
set "MODIG_LOCAL_URL_WITHOUT_PROTOCOL=%MODIG_NGROK_FULL_LOCAL_URL:*//=%"

:: Check for a leading double slash (//) and remove it, if present
if "%MODIG_LOCAL_URL_WITHOUT_PROTOCOL:~0,2%"=="//" set "MODIG_LOCAL_URL_WITHOUT_PROTOCOL=%MODIG_LOCAL_URL_WITHOUT_PROTOCOL:~2%"

SET MODIG_NGROK_URL=%MODIG_NGROK_FULL_LOCAL_URL:~8%
SET MODIG_NGROK_URL=%MODIG_NGROK_URL:~0,-1%

echo Starting ngrok for %MODIG_NGROK_URL% with name %MODIG_NGROK_FULL_LOCAL_URL%

REM Define initial flag variable
SET "FLAGS=--host-header=%MODIG_LOCAL_URL_WITHOUT_PROTOCOL%"

if defined MODIG_NGROK_REMOTE_DOMAIN (
    REM Add new flag to FLAGS variable
    SET "FLAGS=%FLAGS% --domain=%MODIG_NGROK_REMOTE_DOMAIN%"
)

if defined MODIG_NGROK_OAUTH_GOOGLE (
    REM Add new flag to FLAGS variable
    SET "FLAGS=%FLAGS% --oauth=google"
) else (
    if defined MODIG_NGROK_OAUTH_GOOGLE_DOMAIN (
        REM Add new flag to FLAGS variable
        SET "FLAGS=%FLAGS% --oauth=google --oauth-allow-domain=%MODIG_NGROK_OAUTH_GOOGLE_DOMAIN%"
    ) else (
        if defined MODIG_NGROK_OAUTH_GOOGLE_EMAIL (
            REM Add new flag to FLAGS variable
            SET "FLAGS=%FLAGS% --oauth=google --oauth-allow-email=%MODIG_NGROK_OAUTH_GOOGLE_EMAIL%"
        )
    )
)

:: start ngrok in the background
start /b ngrok http %FLAGS% "%MODIG_NGROK_FULL_LOCAL_URL%"

:: Pause for 2 seconds to give ngrok time to start
timeout /t 2

if defined MODIG_NGROK_REMOTE_DOMAIN (
    REM Add new flag to FLAGS variable
    SET NGROK_URL="%PROTOCOL%://%MODIG_NGROK_REMOTE_DOMAIN%"
) else (
    :: Query the ngrok API for the tunnel information and parse it to get the public URL
    for /f "delims=" %%i in ('powershell -File "%~dp0helpers\get-ngrok-url.ps1" -url "%MODIG_NGROK_FULL_LOCAL_URL%"') do set "NGROK_URL=%%i"
)

call "%~dp0helpers\run-linux-script.bat" ngrok-config "%NGROK_URL%"
