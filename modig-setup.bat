@echo off

echo Start Windows setup

REM Call linux script "setup"
call "%~dp0windows-scripts\run-linux-script.bat" setup

REM Run lando rebuild in Windows
lando rebuild -y

REM Check for errors in the lando rebuild command
if %errorlevel% neq 0 (
    echo Lando rebuild failed
    exit /b %errorlevel%
)

REM Stop lando, since port is most likely wrong.
lando stop

echo Script completed successfully. You can now start lando with the command 'lando start'.
