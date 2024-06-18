#!/bin/bash

# Check if ngrok is installed
if ! command -v ngrok &>/dev/null; then
    echo "ngrok is not installed."
    echo "Visit https://ngrok.com/download and download the version for your OS."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "jq is not installed."
    echo "Visit https://stedolan.github.io/jq/download/ and download the version for your OS."
    echo "If you have one, you can usually use your package manager to install it."
    exit 1
fi

# Check if MODIG_NGROK_FULL_LOCAL_URL is set and if not, get the URL from lando
if [ -z "$MODIG_NGROK_FULL_LOCAL_URL" ]; then
    MODIG_NGROK_FULL_LOCAL_URL=$(lando info --format json | jq -r '.[0].urls[3]')
fi

# Extract the protocol (http or https)
PROTOCOL=${MODIG_NGROK_FULL_LOCAL_URL%%:*}

# Remove any trailing slash
MODIG_NGROK_FULL_LOCAL_URL="${MODIG_NGROK_FULL_LOCAL_URL%/}"

# Remove the protocol
MODIG_LOCAL_URL_WITHOUT_PROTOCOL="${MODIG_NGROK_FULL_LOCAL_URL#*//}"

# Check for a leading double slash (//) and remove it, if present
if [[ "$MODIG_LOCAL_URL_WITHOUT_PROTOCOL" == //* ]]; then
    MODIG_LOCAL_URL_WITHOUT_PROTOCOL="${MODIG_LOCAL_URL_WITHOUT_PROTOCOL:2}"
fi

echo "Starting ngrok for $MODIG_NGROK_FULL_LOCAL_URL"

# Define initial flag variable
FLAGS="--host-header=rewrite"

if [ -n "$MODIG_NGROK_REMOTE_DOMAIN" ]; then
    FLAGS="$FLAGS --domain=$MODIG_NGROK_REMOTE_DOMAIN"
fi

if [ -n "$MODIG_NGROK_OAUTH_GOOGLE" ]; then
    FLAGS="$FLAGS --oauth=google"
elif [ -n "$MODIG_NGROK_OAUTH_GOOGLE_DOMAIN" ]; then
    FLAGS="$FLAGS --oauth=google --oauth-allow-domain=$MODIG_NGROK_OAUTH_GOOGLE_DOMAIN"
elif [ -n "$MODIG_NGROK_OAUTH_GOOGLE_EMAIL" ]; then
    FLAGS="$FLAGS --oauth=google --oauth-allow-email=$MODIG_NGROK_OAUTH_GOOGLE_EMAIL"
fi

# Start ngrok in the background
ngrok http $FLAGS "$MODIG_NGROK_FULL_LOCAL_URL" &

# Pause for 2 seconds to give ngrok time to start
sleep 2

if [ -n "$MODIG_NGROK_REMOTE_DOMAIN" ]; then
    MODIG_NGROK_REMOTE_URL="$PROTOCOL://$MODIG_NGROK_REMOTE_DOMAIN"
else
    # Query the ngrok API for the tunnel information and parse it to get the public URL
    MODIG_NGROK_REMOTE_URL=$(./get-ngrok-url.sh -url "$MODIG_NGROK_FULL_LOCAL_URL")
fi

NGROK_URL="$MODIG_NGROK_REMOTE_URL"
execute_part "config-ngrok" "ngrok"
