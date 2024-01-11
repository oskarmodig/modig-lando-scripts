#!/bin/bash

# AVAILABLE ARGUMENTS
#    MOD_VAR_POT_FILENAME      - Name of live pot file to create/update.
#    MOD_VAR_POT_DOMAIN        - Text domain of strings in code. Defaults to MOD_VAR_POT_FILENAME.
#    MOD_VAR_POT_DIR           - Name of dir to place pot-file in. Defaults to "languages".
#    MOD_VAR_POT_EXCLUDES      - Added to the default --exclude parameter.
#    MOD_VAR_PATH_TO_TRANSLATE - Path to dir to search for strings to translate. Defaults to ".".

# Check for required argument
check_required_vars "You have to supply MOD_VAR_POT_FILENAME" MOD_VAR_POT_FILENAME

change_dir "$MOD_VAR_PACKAGE_PATH" "Package path not found."

# Set defaults if not provided
MOD_VAR_POT_DOMAIN=${MOD_VAR_POT_DOMAIN:-$MOD_VAR_POT_FILENAME}
MOD_VAR_POT_DIR=${MOD_VAR_POT_DIR:-"languages"}
MOD_VAR_WP_PATH=${MOD_VAR_WP_PATH:-"wordpress"}
MOD_VAR_PATH_TO_TRANSLATE=${MOD_VAR_PATH_TO_TRANSLATE:-"."}

# Create the directory
create_dir "$MOD_VAR_POT_DIR"

# Define an array for the excludes
declare -a excludes=(
  "wordpress"
  "node_modules"
  "deploy"
  "testsuite"
  "vendor"
)

# If additional excludes are provided, append them
if [ -n "$MOD_VAR_POT_EXCLUDES" ]; then
  IFS=',' read -ra EXTRA_EXCLUDES <<< "$MOD_VAR_POT_EXCLUDES"
  excludes=("${excludes[@]}" "${EXTRA_EXCLUDES[@]}")
fi

# Create a string from the array for the wp command
exclude_str=$(IFS=,; echo "${excludes[*]}")

# Create the .pot file
wp i18n make-pot "$MOD_VAR_PATH_TO_TRANSLATE" "$MOD_VAR_POT_DIR/$MOD_VAR_POT_FILENAME.pot" --domain="$MOD_VAR_POT_DOMAIN" --exclude="$exclude_str" --path="$MOD_VAR_WP_PATH"

echo_progress "POT creation finished"
