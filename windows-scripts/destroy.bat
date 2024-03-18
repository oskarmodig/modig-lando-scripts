@echo off

echo Destroy Wordpress setup

call "%~dp0helpers\read-env-files.bat" :readEnvFile .setup.modig.env
call "%~dp0helpers\read-env-files.bat" :readEnvFile .setup.modig.secret.env

call "%~dp0helpers\run-linux-command.bat" "'lando rebuild -y'"
call "%~dp0helpers\run-linux-script.bat" destroy

echo lando was destroyed successfully.
