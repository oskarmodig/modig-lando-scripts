#!/bin/bash
call_wp config set set WP_LOCAL_NGROK_URL "$NGROK_URL"

echo "ngrok url: $NGROK_URL"
echo "ngrok web interface: http://localhost:4040"
