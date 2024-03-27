@echo off

REM Get Unix-like USER environment variable
for /f "tokens=* delims=" %%a in ('wsl echo $USER') do set "unix_user=%%a"

REM Check if current user is root
if "%unix_user%"=="root" (
    REM Prompt for the WSL Linux user, if not already set
    if not defined MODIG_SETUP_LINUX_USER (
        set /p MODIG_SETUP_LINUX_USER="Enter your WSL Linux username: "
    )
)
