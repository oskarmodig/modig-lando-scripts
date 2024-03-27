@echo off

echo Destroy Wordpress setup

call "%~dp0helpers\load-env.bat"

call "%~dp0helpers\run-linux-command.bat" "'lando rebuild -y'"
call "%~dp0helpers\run-linux-script.bat" destroy

echo lando was destroyed successfully.
