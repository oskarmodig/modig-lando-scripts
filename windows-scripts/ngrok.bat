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

if not defined MODIG_NGROK_FULL_URL (
    REM Get the https url from lando
    FOR /F "usebackq tokens=*" %%a IN (`lando info --format json ^| jq ".[0].urls[3]"`) DO SET MODIG_NGROK_FULL_URL=%%~a
)

:: Check if the URL contains a port
echo.!MODIG_NGROK_FULL_URL! | findstr /R /C:":.*:" >nul
if errorlevel 1 (
    :: Extract the protocol (http or https)
    for /f "tokens=1 delims=:" %%a in ("!MODIG_NGROK_FULL_URL!") do set PROTOCOL=%%a

    :: No port found, decide which port to add based on the protocol
    if "!PROTOCOL!"=="http" (
        set MODIG_NGROK_FULL_URL=!MODIG_NGROK_FULL_URL!:80
    ) else if "!PROTOCOL!"=="https" (
        set MODIG_NGROK_FULL_URL=!MODIG_NGROK_FULL_URL!:443
    )
)

REM Strip off the protocol
SET MODIG_NGROK_URL=%MODIG_NGROK_FULL_URL:~8%
SET MODIG_NGROK_URL=%MODIG_NGROK_URL:~0,-1%

echo Starting ngrok for %MODIG_NGROK_URL% with name %MODIG_NGROK_FULL_URL%

REM start ngrok in the background
start /b ngrok http --host-header="%MODIG_NGROK_URL%" "%MODIG_NGROK_FULL_URL%"

REM Pause for 2 seconds to give ngrok time to start
timeout /t 2 >null

REM Query the ngrok API for the tunnel information and parse it to get the public URL
for /f "delims=" %%i in ('powershell -Command "$url = '\''!MODIG_NGROK_FULL_URL!'\''; (Invoke-RestMethod http://localhost:4040/api/tunnels).tunnels | Where-Object { $_.config.addr -eq $url } | Select-Object -ExpandProperty public_url -First 1"') do set "NGROK_URL=%%i"

call "%~dp0helpers\run-linux-script.bat" ngrok-config %NGROK_URL%
