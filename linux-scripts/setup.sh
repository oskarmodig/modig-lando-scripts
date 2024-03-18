#!/bin/bash

# Start lando if this is not a Windows machine
if [ "$MOD_LOC_SCRIPT_ENVIRONMENT" != "windows" ]; then
    echo_progress "Starting lando"
    lando start
fi

# Example usage for plugins
PLUGINS="plugin-url-1,special-plugin-1,plugin-name-2,special-plugin-2"
declare -A special_plugins
special_plugins[woocommerce]="execute_part \"install-woocommerce\""
install_wp_items "plugin" "$PLUGINS" special_plugins

# Example usage for themes
THEMES="theme-name-1,special-theme-1,theme-url-2,special-theme-2"
declare -A special_themes
special_themes[storefront]="execute_part \"install-storefront\""
install_wp_items "theme" "$THEMES" special_themes

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
