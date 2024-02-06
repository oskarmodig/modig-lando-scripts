@echo off

if not defined LINUX_USER (
    call "%~dp0get-linux-user.bat"
)

REM Pass arguments from batch file to shell script in WSL
wsl sudo -u %LINUX_USER% bash -c -i "%1"

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
