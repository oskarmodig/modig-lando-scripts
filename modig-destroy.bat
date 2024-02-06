@echo off

echo Destroy Wordpress setup

call windows-scripts\run-linux-command.bat "lando rebuild -y"
call windows-scripts\run-linux-script.bat "destroy"

echo lando was destroyed successfully.
