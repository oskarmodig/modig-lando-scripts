#!/bin/bash

# MOD_INP_*
#
# These are variables that are set by the user in the lando.yml file
# As options when calling this script file.
# Mainly used to determine environment for current execution.
# E.g., 'plugin' or 'theme'? 'test' or not?
#
# Available options:
# - MOD_INP_SCRIPT (required): The script to run (e.g., 'deploy' or 'make-pot'). See case below for available scripts.
#
# - MOD_INP_ENV (optional): The environment to get variables for (e.g., 'BOOK_PL' for Booking plugin).
#                   MOD_VAR variables (described below) are set based on this value.
#                   E.g., for 'BOOK_PL', MOD_VAR__BOOK_PL__* variables are used.
#                   If this is not set, MOD_VAR_* variables (without extra prefix) are used.
#
# - MOD_INP_TEST (optional): Whether to use test variables or not (e.g., 'true' or 'false').
#                   If this is set to 'true', the script will use MOD_VAR__TEST__* variables instead of MOD_VAR_*.
#                   And if used with MOD_INP_ENV, it will use MOD_VAR__${MOD_INP_ENV}__TEST__* variables.
#                   E.g., for 'BOOK_PL', MOD_VAR__BOOK_PL__TEST__* variables are used.

# MOD_VAR_*
#
# Variables set mainly in .env files
# In the .env files they can also be set as MOD_VAR__[env]__*, to allow different environments in the same lando app
# This requires the MOD_INP_ENV variable to be set to the same value as [env] in the .env file
#
# General variables, for all scripts:
# - MOD_VAR_PACKAGE (semi-optional): The name of the package, defaults to Lando app name if available.
# - MOD_VAR_PACKAGE_PATH (optional): The path to the package files, defaults to /app.
# - MOD_VAR_PACKAGE_TYPE (optional): The type of package, defaults to 'plugin'.
# - MOD_VAR_WP_PATH (optional):      The path to the WordPress files, defaults to 'wordpress'.
#
# More variables are documented in the individual script files.

# Get directory of this script
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# Load variables
. "$DIR/helpers/load-variables.sh"

# Load helpers
. "$DIR/helpers/output.sh"
. "$DIR/helpers/helpers.sh"

# Set value for MOD_VAR_PACKAGE_TYPE if not provided
MOD_VAR_PACKAGE_TYPE=${MOD_VAR_PACKAGE_TYPE:-"plugin"}

# Change directory to the package path
MOD_VAR_PACKAGE_PATH=${MOD_VAR_PACKAGE_PATH:-"/app"}

# Determine the package name, either from the provided variable or from the LANDO_APP_NAME
if [ -z "$MOD_VAR_PACKAGE" ]; then
    if [ -n "$LANDO_APP_NAME" ]; then
        MOD_VAR_PACKAGE=$LANDO_APP_NAME
    else
        exit_script "You have to supply a plugin/theme name in MOD_VAR_PACKAGE"
    fi
fi

# Set WordPress path if not provided
MOD_VAR_WP_PATH=${MOD_VAR_WP_PATH:-"wordpress"}


# SELECT SCRIPT TO RUN
case $MOD_INP_SCRIPT in

  deploy)
    . "$DIR/deploy.sh"
    ;;

  make-pot)
    . "$DIR/make-pot.sh"
    ;;

  *)
    exit_script "You have entered an invalid script, please try again."
    ;;
esac
