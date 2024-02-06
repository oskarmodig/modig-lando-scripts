@echo off

echo Start Windows script

set "windowsScriptPath=%~dp0windows-scripts\%1.bat"

REM Check if the batch file exists
if exist "%windowsScriptPath%" (
    call "%windowsScriptPath%"
) else (
    echo Error: The batch file "%windowsScriptPath%" does not exist.
)
