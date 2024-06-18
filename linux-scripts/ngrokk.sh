#!/bin/bash

# Kill ngrok in Linux if not on a Windows machine
if [ "$MOD_LOC_SCRIPT_ENVIRONMENT" != "windows" ]; then
    pkill ngrok
    echo "ngrok has been killed."
fi

execute_part "deconfig-ngrok" "ngrok"
