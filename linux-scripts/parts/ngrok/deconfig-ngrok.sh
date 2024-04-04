#!/bin/bash

lando ssh -c "rm \"$MOD_LOC_ABSOLUT_WP_PATH/wp-content/mu-plugins/ngrok-local.php\""

call_wp config delete WP_NGROK_REMOTE_URL
