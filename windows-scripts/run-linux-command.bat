@echo off

if not defined LINUX_USER (
    call "%~dp0get-linux-user.bat"
)

echo Running linux command %2 in %1, as user %LINUX_USER%

REM Pass arguments from batch file to shell script in WSL
wsl sudo -u %LINUX_USER% bash -c -i "%~1 %~2"

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
