@echo off

echo Start Windows script

set "windowsScriptPath=%~dp0windows-scripts\%1.bat"

REM If paramter 2 is set, use it as the WSL Linux user
if not "%2" == "" (
    set "LINUX_USER=%2"
)

REM Check if the batch file exists
if exist "%windowsScriptPath%" (
    call "%windowsScriptPath%"
) else (
    echo Error: The batch file "%windowsScriptPath%" does not exist.
)
