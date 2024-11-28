#!/bin/bash

load_env_file ".modig.lando.global.env"
load_env_file ".modig.lando.local.env"

# Start lando if this is not a Windows machine
if [ "$MOD_LOC_SCRIPT_ENVIRONMENT" != "windows" ]; then
    echo_progress "Starting lando"
    lando start
fi

# Build lando
execute_part "install-wordpress"

if [ -n "$MODIG_SETUP_PLUGINS" ]; then
    declare -A special_plugins
    # shellcheck disable=SC2034
    special_plugins[woocommerce]="install_woocommerce"
    install_wp_items "plugin" "$MODIG_SETUP_PLUGINS" special_plugins
fi

if [ -n "$MODIG_SETUP_THEMES" ]; then
    declare -A special_themes
    # shellcheck disable=SC2034
    special_themes[storefront]="install_storefront"
    install_wp_items "theme" "$MODIG_SETUP_THEMES" special_themes
fi

# If composer.json exists, run composer install
if [ -f "composer.json" ]; then
    echo_progress "Running composer install"
    lando composer install
fi

if [ -n "$MODIG_SETUP_MULTISITE" ] || [ -n "$MODIG_SETUP_MULTISITE_DIR" ]; then
    execute_part "setup-multisite"
fi

execute_part "update-translations"

# TODO: Check if we should run composer install and/or npm install

echo_progress "Creating symlink for package"
lando mount

# Create .htaccess file with contents
execute_part "create-htaccess"

# Echo the site URL
lando info --format json | jq '.[0].urls[-1]' | tr '"' ' '
