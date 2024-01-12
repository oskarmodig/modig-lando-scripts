@echo off

REM Dummy read to clear any residual input
echo Start Windows setup

REM Prompt for the WSL Linux user
set /p LINUX_USER="Enter your WSL Linux username: "

REM Pass arguments from batch file to shell script in WSL
wsl sudo -u %LINUX_USER% bash -c vendor/bin/modig-linux-script.sh %*


REM Check for errors in the WSL command
if %errorlevel% neq 0 (
    echo WSL command failed.
    choice /M "Do you want to continue anyway"
    if errorlevel 2 goto abort
)

echo Continuing...
goto end_script

:abort
echo Aborting...
exit /b %errorlevel%

:end_script

REM Run lando rebuild in Windows
lando rebuild

REM Check for errors in the lando rebuild command
if %errorlevel% neq 0 (
    echo Lando rebuild failed
    exit /b %errorlevel%
)

echo Script completed successfully
