#!/bin/bash

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
MOD_LOC_SCRIPT_ENVIRONMENT=${2:-"linux"}

# shellcheck disable=SC2034
MOD_LOC_SCRIPT_TYPE=linux

# Basic script setup
. "$MOD_LOC_SCRIPTS_BASE_DIR/_setup-scripts.sh"

# Check if lando is installed
. "$MOD_LOC_CURRENT_SCRIPT_DIR/helpers/lando-command-check.sh"

# WP CLI helper
. "$MOD_LOC_CURRENT_SCRIPT_DIR/helpers/run-wp-command.sh"

# Get lando app name
# shellcheck disable=SC2034
MOD_LOC_LANDO_APP_NAME=$(grep 'name:' .lando.yml | awk '{print $2}' | tr -d '\r\n')




# Get path where script was called
MOD_LOC_SCRIPT_CALLED_FROM=$(pwd)

# Path to WordPress
# shellcheck disable=SC2034
MOD_LOC_WORDPRESS_PATH="$MOD_LOC_SCRIPT_CALLED_FROM/wordpress"

## These were intended to be used to load .env files from .lando.yml, but it's not being used anywhere.
# Path to lando config file
# shellcheck disable=SC2034
# MOD_LOC_LANDO_FILE="$MOD_LOC_SCRIPT_CALLED_FROM/.lando.yml"
# . "$MOD_LOC_CURRENT_SCRIPT_DIR/helpers/load-lando-env-files.sh"
# . "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/load-lando-env-vars.sh"
# . "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/parse-main-variables.sh"

# Default script to run
MOD_INP_SCRIPT=${1:-"setup"}

echo "Running script: $MOD_INP_SCRIPT"

. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/run-main-script.sh"
