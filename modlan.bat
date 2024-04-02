@echo off

echo Start Windows script

call "%~dp0windows-scripts\helpers\load-env.bat"

set "windowsScriptPath=%~dp0windows-scripts\%1.bat"

REM If paramter 2 is set, use it as the WSL Linux user
if not "%2" == "" (
    set "MODIG_LINUX_USER=%2"
)

REM Check if the batch file exists
if exist "%windowsScriptPath%" (
    call "%windowsScriptPath%"
) else (
    set "MODIG_WIN_SCRIPT=%1"
    call "%~dp0windows-scripts\default.bat"
)
