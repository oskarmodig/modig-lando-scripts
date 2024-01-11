#!/bin/bash

if [ -f "$MOD_LOC_CURRENT_SCRIPT_DIR/$MOD_INP_SCRIPT.sh" ]; then
  # shellcheck disable=SC1090
  . "$MOD_LOC_CURRENT_SCRIPT_DIR/$MOD_INP_SCRIPT.sh"
else
  exit_script "You have entered an invalid script, please try again."
fi
