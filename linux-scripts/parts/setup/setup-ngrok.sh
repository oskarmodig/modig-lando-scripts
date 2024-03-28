#!/bin/bash

# Setup plugin for ngrok
echo_progress "Installing WP-Ngrok-Local"

lando ssh -c "mkdir -p \"$MOD_LOC_ABSOLUT_WP_PATH/wp-content/mu-plugins\" && ln -sf var/www/.composer/vendor/oskarmodig/lando-scripts/included-vendor/wp-ngrok-local/ngrok-local.php \"$MOD_LOC_ABSOLUT_WP_PATH/wp-content/mu-plugins/ngrok-local.php\""
