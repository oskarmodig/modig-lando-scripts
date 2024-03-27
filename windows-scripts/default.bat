@echo off

echo "Start Windows script %MODIG_WIN_SCRIPT%"

REM Call linux script "setup"
call "%~dp0helpers\run-linux-script.bat" %MODIG_WIN_SCRIPT%

REM Check for errors in the lando rebuild command
if %errorlevel% neq 0 (
    echo %MODIG_WIN_SCRIPT% failed
    exit /b %errorlevel%
)

echo Script completed successfully.
