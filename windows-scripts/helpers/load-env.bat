@echo off

call "%~dp0read-env-file.bat" .setup.modig.env
call "%~dp0read-env-file.bat" .setup.modig.secret.env

@call "%temp%\modigLandoScriptEnvVars.bat"
@del "%temp%\modigLandoScriptEnvVars.bat"

call "%~dp0get-linux-user.bat"
