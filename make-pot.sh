#!/bin/bash

# AVAILABLE ARGUMENTS
#    MOD_VAR_FILENAME  - Name of live pot file to create/update.
#    MOD_VAR_DOMAIN    - Text domain of strings in code. Defaults to MOD_VAR_FILENAME.
#    MOD_VAR_DIR       - Name of dir to place pot-file in. Defaults to "languages".
#    MOD_VAR_EXCLUDES  - Added to the default --exclude parameter.
#    MOD_VAR_WP_PATH   - Path to wordpress installation. Defaults to "wordpress". Pass "." to use current directory.

if [ -z "$MOD_VAR_FILENAME" ]
then
  echo "You have to supply MOD_VAR_FILENAME";
  exit 1;
fi

if [ -n "$MOD_VAR_DOMAIN" ]
then
  MOD_VAR_DIR="$MOD_VAR_FILENAME"
fi

if [ -n "$MOD_VAR_DIR" ]
then
  MOD_VAR_DIR="languages"
fi

if [ -z "$MOD_VAR_WP_PATH" ]
then
  MOD_VAR_WP_PATH="wordpress"
fi

if [ -z "$MOD_VAR_EXCLUDES" ]
then
  MOD_VAR_EXCLUDES=",$MOD_VAR_EXCLUDES"
else
  MOD_VAR_EXCLUDES=""
fi

mkdir -p "$MOD_VAR_DIR"

wp i18n make-pot . "$MOD_VAR_DIR/$MOD_VAR_FILENAME.pot" --domain="$MOD_VAR_DOMAIN" --exclude="wordpress,node_modules,deploy,swish,testsuite,vendor$MOD_VAR_EXCLUDES" --path="$MOD_VAR_WP_PATH"

echo "POT creation finished"
