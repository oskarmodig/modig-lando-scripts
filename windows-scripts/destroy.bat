@echo off

echo Destroy Wordpress setup

call "%~dp0helpers\read-env-files.bat" .setup.modig.env
call "%~dp0helpers\read-env-files.bat" .setup.modig.secret.env
@call "%temp%\modigLandoScriptEnvVars.bat"
@del "%temp%\modigLandoScriptEnvVars.bat"

call "%~dp0helpers\run-linux-command.bat" "'lando rebuild -y'"
call "%~dp0helpers\run-linux-script.bat" destroy

echo lando was destroyed successfully.
