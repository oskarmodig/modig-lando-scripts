#!/bin/bash

echo_progress "Installing WordPress"

rm -rf wordpress && mkdir wordpress
lando wp core download --path=wordpress
lando wp config create --dbname=wordpress --dbuser=wordpress --dbpass=wordpress --dbhost=database --path=wordpress --dbprefix=wp_
lando wp core install --url="$MOD_LOC_LANDO_APP_NAME".lndo.site --title="$MOD_LOC_LANDO_APP_NAME DEV" --admin_user=admin --admin_password=password --admin_email=user@example.com --path=wordpress

lando wp config set WP_ENVIRONMENT_TYPE local --path=wordpress
lando wp config set WP_DEBUG true --raw --path=wordpress
lando wp config set WP_DEBUG_DISPLAY true --raw --path=wordpress
lando wp config set WP_DEBUG_LOG '/app/wordpress/wp-content/debug.log' --raw --path=wordpress


echo_progress "Installing WooCommerce"
lando wp plugin install woocommerce --activate --path=wordpress

echo_progress "Installing Storefront"
lando wp theme install storefront --activate --path=wordpress

echo_progress "Setting timezone to Stockholm"
wp option update timezone_string "Europe/Stockholm" --path=wordpress

echo_progress "Install and activate Swedish"
lando wp language core install sv_SE --path=wordpress
lando wp language core activate sv_SE --path=wordpress

echo_progress "Set up multisite"
lando wp core multisite-install --title="$MOD_LOC_LANDO_APP_NAME DEV" --admin_user="admin" --admin_password="password" --admin_email="user@example.com" --path=wordpress

echo_progress "Creating symlink for package"
# Symlink package path to plugins/themes folder
MOD_LOC_WP_CONTENT_SUB_FOLDER="$MOD_VAR_PACKAGE_TYPE"s
cd "$MOD_LOC_WORDPRESS_PATH"/wp-content/"$MOD_LOC_WP_CONTENT_SUB_FOLDER"/ && ln -snf ../../../ "$MOD_LOC_LANDO_APP_NAME"
