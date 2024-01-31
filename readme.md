# Modig Lando Scripts
## Setup
### Windows
You need WSL 2 running, the correct distro as default
(check with `wsl --list --verbose` and `wsl --set-default Ubuntu`, for instance).

Also, you probably need to add this to your `/etc/wsl.conf` file (in WSL)
```
[automount]
options = "metadata,umask=22,fmask=11"
```

Then, make sure you have a Linux user that is not `root`, it might need sudo permissions though.
Also, make sure your Linux user is the owner of the project files.

Add a file like this to your project root, for easy setup:
```bat
@echo off
REM .\vendor\bin\modig-windows-script.bat MOD_INP_ENV=your_plugin MOD_INP_SCRIPT=setup
.\vendor\bin\modig-windows-script.bat
```

You should the be able to run setup with `.\.lando-setup.bat`.

### Unix
You should be fine running `bash vendor/bin/modig-linux-script.sh MOD_INP_ENV=your_plugin MOD_INP_SCRIPT=setup` directly
