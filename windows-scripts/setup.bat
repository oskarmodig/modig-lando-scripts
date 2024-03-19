@echo off

echo Start Windows setup
call "%~dp0helpers\read-env-files.bat" .setup.modig.env
call "%~dp0helpers\read-env-files.bat" .setup.modig.secret.env

@call "%temp%\modigLandoScriptEnvVars.bat"
@del "%temp%\modigLandoScriptEnvVars.bat"

call "%~dp0helpers\get-linux-user.bat"

lando start

REM Call linux script "setup"
call "%~dp0helpers\run-linux-script.bat" setup

REM Check for errors in the lando rebuild command
if %errorlevel% neq 0 (
    echo Setup failed
    exit /b %errorlevel%
)

echo Script completed successfully. If lando started on a custom port, try running "lando rebuild".
