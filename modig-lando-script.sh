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

# Basic script setup
. "$MOD_LOC_SCRIPTS_BASE_DIR/_setup.sh"

. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/load-lando-env-vars.sh"

. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/parse-main-variables.sh"


# Set package path if not provided
MOD_VAR_PACKAGE_PATH=${MOD_VAR_PACKAGE_PATH:-"/app"}

# Set WordPress path if not provided
MOD_VAR_WP_PATH=${MOD_VAR_WP_PATH:-"wordpress"}

# Go to package path
change_dir "$MOD_VAR_PACKAGE_PATH" "Package path not found."

. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/run-main-script.sh"
