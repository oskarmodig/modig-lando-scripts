#!/bin/bash

# Start lando
lando start

# Build lando
execute_part "install-wordpress"

echo_progress "Creating symlink for package"
# Symlink package path to plugins/themes folder
MOD_LOC_WP_CONTENT_SUB_FOLDER="$MOD_VAR_PACKAGE_TYPE"s
cd "$MOD_LOC_WORDPRESS_PATH"/wp-content/"$MOD_LOC_WP_CONTENT_SUB_FOLDER"/ && ln -snf ../../../ "$MOD_LOC_LANDO_APP_NAME"

# Create an empty debug.log file
touch "/$MOD_LOC_WORDPRESS_PATH/wp-content/debug.log"

# Create .htaccess file with contents
execute_part "create-htaccess" # TODO: This is not loading
