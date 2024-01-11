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
# - MOD_INP_ENV (required): The environment to get variables for (e.g., 'BOOK_PL' for Booking plugin).
#                   MOD_VAR variables (described below) are set based on this value.
#                   E.g., for 'BOOK_PL', MOD_VAR__BOOK_PL__* variables are used.
#                   If this is not set, MOD_VAR_* variables (without extra prefix) are used.
#
# - MOD_INP_TEST (optional): Whether to use test variables or not (e.g., 'true' or 'false').
#                   If this is set to 'true', the script will MOD_VAR__${MOD_INP_ENV}_TEST__* variables over MOD_VAR__${MOD_INP_ENV}__*.
#                   E.g., for 'BOOK_PL', MOD_VAR__BOOK_PL__TEST__* variables are used.
#                   However, if a MOD_VAR__${MOD_INP_ENV}_TEST__* variable is not set, the script will fall back to MOD_VAR__${MOD_INP_ENV}__*.
#
#
#
# MOD_VAR_*
#
# Variables set mainly in .env files
# In the .env files they can also be set as MOD_VAR__[env]__*, to allow different environments in the same lando app
# This requires the MOD_INP_ENV variable to be set to the same value as [env] in the .env file
#
# General MOD_VARs:
# - MOD_VAR_PACKAGE_NAME (semi-optional): The name of the package as seen by WordPress (plugin/theme folder name), defaults to Lando app name if available.
# - MOD_VAR_PACKAGE_TYPE (optional):      The type of package, defaults to 'plugin'.
#
# More variables are documented in the individual script files.
#
#
#
#
# MOD_LOC_*
#
# Set in the individual script files, and are not meant to be set by the user.
#
#
# MOD_READ_*
#
# Set by prompting user for input.
# User should be prompted as soon as possible in the script, to avoid them having to wait for the script to run before being prompted.

# shellcheck disable=SC2034
MOD_LOC_CURRENT_SCRIPT_DIR="$MOD_LOC_SCRIPTS_BASE_DIR/$MOD_LOC_SCRIPT_TYPE-scripts"

# Load variables
. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/load-input-variables.sh"

# Load helpers
. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/output.sh"
. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/helpers.sh"
. "$MOD_LOC_SCRIPTS_BASE_DIR/helpers/execute-parts.sh"
