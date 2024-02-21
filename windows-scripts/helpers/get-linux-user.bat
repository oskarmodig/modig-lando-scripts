@echo off

REM Prompt for the WSL Linux user, if not already set
if not defined LINUX_USER (
    set /p LINUX_USER="Enter your WSL Linux username: "
)
