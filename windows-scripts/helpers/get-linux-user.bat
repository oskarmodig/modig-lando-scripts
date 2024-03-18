@echo off

REM Prompt for the WSL Linux user, if not already set
if not defined MODIG_LINUX_USER (
    set /p MODIG_LINUX_USER="Enter your WSL Linux username: "
)
