@echo off

echo Start Windows setup

REM Call linux script "setup"
call "%~dp0helpers\run-linux-script.bat" setup

REM Run lando rebuild in Windows
lando rebuild -y

REM Check for errors in the lando rebuild command
if %errorlevel% neq 0 (
    echo Lando rebuild failed
    exit /b %errorlevel%
)

echo Script completed successfully. If lando started on a custom port, try running "lando rebuild".
