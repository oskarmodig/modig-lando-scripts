#!/bin/bash

echo_progress "Installing WordPress"

# Remove any existing wordpress folder
lando ssh -c "rm -rf \"$MOD_LOC_ABSOLUT_WP_PATH\" && mkdir \"$MOD_LOC_ABSOLUT_WP_PATH\""

call_wp core download
call_wp config create --dbname=wordpress --dbuser=wordpress --dbpass=wordpress --dbhost=database --dbprefix=wp_
call_wp core install --url="$MOD_LOC_LANDO_APP_NAME".lndo.site --title="$MOD_LOC_LANDO_APP_NAME DEV" --admin_user=admin --admin_password=password --admin_email=user@example.com

call_wp config set WP_ENVIRONMENT_TYPE local
call_wp config set WP_DEBUG true --raw
call_wp config set WP_DEBUG_DISPLAY true --raw

# Set up debug log
DEBUG_LOG_PATH="$MOD_LOC_ABSOLUT_WP_PATH/wp-content/debug.log"
call_wp config set WP_DEBUG_LOG "\"$DEBUG_LOG_PATH\""
lando ssh -c "touch \"$DEBUG_LOG_PATH\""

call_wp option update permalink_structure '/%postname%/'

echo_progress "Installing WooCommerce"
call_wp plugin install woocommerce --activate

execute_part "setup-woocommerce"

echo_progress "Installing Storefront"
call_wp theme install storefront --activate

echo_progress "Setting timezone to Stockholm"
call_wp option update timezone_string "Europe/Stockholm"

echo_progress "Install and activate Swedish"
call_wp language core install sv_SE
call_wp site switch-language sv_SE

echo_progress "Set up multisite"
call_wp core multisite-install --title="$MOD_LOC_LANDO_APP_NAME DEV" --admin_user="admin" --admin_password="password" --admin_email="user@example.com"

echo_progress "Update translations"
call_wp language plugin update --all
call_wp language theme update --all
call_wp language core update
