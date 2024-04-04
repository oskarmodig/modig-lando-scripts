#!/bin/bash

lando ssh -c "mkdir -p \"$MOD_LOC_ABSOLUT_WP_PATH/wp-content/mu-plugins\" && ln -sf /var/www/.composer/vendor/oskarmodig/lando-scripts/included-vendor/wp-ngrok-local/ngrok-local.php \"$MOD_LOC_ABSOLUT_WP_PATH/wp-content/mu-plugins/ngrok-local.php\""

call_wp config set WP_NGROK_REMOTE_URL "$NGROK_URL"

echo "ngrok url: $NGROK_URL"
echo "ngrok web interface: http://localhost:4040"
