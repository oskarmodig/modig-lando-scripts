@echo off

call "%~dp0read-env-file.bat" .modig.lando.global.env
call "%~dp0read-env-file.bat" .modig.lando.local.env

@call "%temp%\modigLandoScriptEnvVars.bat"
@del "%temp%\modigLandoScriptEnvVars.bat"

call "%~dp0get-linux-user.bat"
