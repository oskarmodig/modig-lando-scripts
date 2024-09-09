@echo off

echo Run composer update

REM Call linux script "setup"
call "%~dp0helpers\run-linux-script.bat" co-up

REM Check for errors in the lando rebuild command
if %errorlevel% neq 0 (
    echo Composer update failed
    exit /b %errorlevel%
)
