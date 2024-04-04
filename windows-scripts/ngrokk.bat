@echo off
taskkill /f /im ngrok.exe

REM Call linux script "setup"
call "%~dp0helpers\run-linux-script.bat" ngrokk
