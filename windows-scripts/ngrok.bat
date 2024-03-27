@echo off
REM Share a Lando based WordPress website using ngrok
REM Cal Evans <cal@calevans.com>
REM https://hackernoon.com/lando-wordpress-and-ngrokoh-my

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
    FOR /F "usebackq tokens=*" %%a IN (`lando info --format json ^| jq ".[0].urls[3]"`) DO SET MODIG_NGROK_FULL_URL=%%~a
)


REM Get the https url from lando

REM Strip off the protocol
SET MODIG_NGROK_URL=%MODIG_NGROK_FULL_URL:~8%
SET MODIG_NGROK_URL=%MODIG_NGROK_URL:~0,-1%

echo Starting ngrok for %MODIG_NGROK_URL% with name %MODIG_NGROK_FULL_URL%

REM Pause for 2 seconds
timeout /t 2

ngrok http --host-header="%MODIG_NGROK_URL%" "%MODIG_NGROK_FULL_URL%"
