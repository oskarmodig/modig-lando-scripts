@echo off

echo Start Windows setup

lando start

REM Call linux script "setup"
call "%~dp0helpers\run-linux-script.bat" setup

REM Check for errors in the lando rebuild command
if %errorlevel% neq 0 (
    echo Lando rebuild failed
    exit /b %errorlevel%
)

echo Script completed successfully. If lando started on a custom port, try running "lando rebuild".
