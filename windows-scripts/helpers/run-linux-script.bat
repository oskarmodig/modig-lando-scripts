@echo off

REM Pass arguments from batch file to shell script in WSL
if not defined MODIG_SETUP_LINUX_USER (
    echo Running linux command %1
    wsl bash -c -i "modig-lin.sh %1 windows"
) else (
    echo Running linux command %1, as user %MODIG_SETUP_LINUX_USER%
    wsl sudo -u %MODIG_LINUX_USER% bash -c -i "modig-lin.sh %1 windows"
)

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
