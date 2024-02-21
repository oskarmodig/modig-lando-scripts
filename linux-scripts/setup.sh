#!/bin/bash

# Start lando if this is not a Windows machine
if [ "$MOD_LOC_SCRIPT_ENVIRONMENT" != "windows" ]; then
    echo_progress "Starting lando"
    lando start
fi

# Build lando
execute_part "install-wordpress"

# TODO: Check if we should run composer install and/or npm install

echo_progress "Creating symlink for package"
lando mount

# Create .htaccess file with contents
execute_part "create-htaccess"
