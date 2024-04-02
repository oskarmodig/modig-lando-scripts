#!/bin/bash

# lando MOD_VARs:
# - MOD_VAR_PACKAGE_PATH (optional):      The path to the package files, defaults to /app.
# - MOD_VAR_WP_PATH (optional):           The path to the WordPress files, defaults to 'wordpress'.
#
# More variables are documented in the individual script files.

# Get directory of this script
MOD_LOC_SCRIPTS_BASE_DIR="${BASH_SOURCE%/*}"
# Check if the script directory was successfully retrieved
if [ -z "$MOD_LOC_SCRIPTS_BASE_DIR" ]; then
    # Prompt the user for the script path
    echo "Failed to retrieve the script path automatically."
    read -r -p "Please enter the script path: " user_input
    MOD_LOC_SCRIPTS_BASE_DIR=$user_input
fi

# shellcheck disable=SC2034
MOD_LOC_SCRIPT_TYPE=lando

# Load variables
. "$MOD_LOC_SCRIPTS_BASE_DIR/lando-scripts/helpers/load-input-variables.sh"

# Basic script setup
. "$MOD_LOC_SCRIPTS_BASE_DIR/_setup-scripts.sh"

. "$MOD_LOC_SCRIPTS_BASE_DIR/lando-scripts/helpers/load-lando-env-vars.sh"

# Determine the package name, either from the provided variable or from the LANDO_APP_NAME
if [ -z "$MOD_VAR_PACKAGE_DEV_NAME" ]; then
  check_required_vars "You have to supply a plugin/theme name in MOD_VAR_PACKAGE_DEV_NAME, not found from LANDO_APP_NAME." LANDO_APP_NAME
  MOD_VAR_PACKAGE_DEV_NAME=$LANDO_APP_NAME
fi

. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/parse-main-variables.sh"


# Go to package path
change_dir "$MOD_VAR_PACKAGE_PATH" "Package path not found."

. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/run-main-script.sh"
