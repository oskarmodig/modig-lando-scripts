@echo off

setlocal enabledelayedexpansion

:: Pass arguments from batch file to shell script in WSL

:: Skip the first argument which is passed separately
set ARGS=
set SKIP_NEXT=0
for %%a in (%*) do (
    if "!SKIP_NEXT!"=="1" (
        set ARGS=!ARGS! %%a
    )
    if "%%a"=="windows" (
        set SKIP_NEXT=1
    )
)

if not defined MODIG_SETUP_LINUX_USER (
    echo Running linux script %1
    wsl bash -c -i "modig-lin.sh %1 windows !ARGS!"
) else (
    echo Running linux script %1, as user %MODIG_SETUP_LINUX_USER%
    wsl sudo -u %MODIG_LINUX_USER% bash -c -i "modig-lin.sh %1 windows !ARGS!"
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
