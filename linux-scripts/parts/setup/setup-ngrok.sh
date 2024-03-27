#!/bin/bash

# Setup plugin for ngrok
echo_progress "Installing WP-Ngrok-Local"

lando ssh -c "mkdir -p \"$MOD_LOC_ABSOLUT_WP_PATH/wp-content/mu-plugins\""
fileContent=$(cat "$MOD_LOC_CURRENT_SCRIPT_DIR"/vendor/wp-ngrok-local/ngrok-local.php)

echo "$fileContent" | lando ssh -c "cat > \"$MOD_LOC_ABSOLUT_WP_PATH/wp-content/mu-plugins/wp-ngrok-local.php\""
