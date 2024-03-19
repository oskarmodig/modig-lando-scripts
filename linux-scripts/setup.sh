#!/bin/bash

load_env_file ".setup.modig.env"
load_env_file ".setup.modig.secret.env"

# Start lando if this is not a Windows machine
if [ "$MOD_LOC_SCRIPT_ENVIRONMENT" != "windows" ]; then
    echo_progress "Starting lando"
    lando start
fi

# Echo current env variables
echo_progress "Current environment variables"
env

if [ -n "$MODIG_PLUGINS" ]; then
    declare -A special_plugins
    # shellcheck disable=SC2034
    special_plugins[woocommerce]="execute_part \"install-woocommerce\""
    install_wp_items "plugin" "$MODIG_PLUGINS" special_plugins
fi

if [ -n "$MODIG_THEMES" ]; then
    declare -A special_themes
    # shellcheck disable=SC2034
    special_themes[storefront]="execute_part \"install-storefront\""
    install_wp_items "theme" "$MODIG_THEMES" special_themes
fi

# Build lando
execute_part "install-wordpress"

if [ -n "$MODIG_SETUP_MULTISITE" ]; then
    execute_part "setup-multisite"
fi

execute_part "update-translations"

# TODO: Check if we should run composer install and/or npm install

echo_progress "Creating symlink for package"
lando mount

# Create .htaccess file with contents
execute_part "create-htaccess"
