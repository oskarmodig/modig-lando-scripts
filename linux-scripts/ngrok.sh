#!/usr/bin/env bash
set -eo pipefail

#
# Share a Lando based WordPress website using ngrok
# Cal Evans <cal@calevans.com>
# https://hackernoon.com/lando-wordpress-and-ngrokoh-my
#
# This script must be run OUTSIDE of the Lando environment but in the Lando dir.
# It uses the lando info command which is not available inside of the lando container.
#
# This is designed to work with a WordPress recipe. To make WordPress play nice
# you have to install the plugin at https://github.com/jonathanbardo/WP-Ngrok-Local
# Once you have that installed and activated, run this script and then visit
# the https URL that it shows.
#
# When you are done, press CTRL+C to exit.
#

#
# Check for sane environment
#
if ! command -v ngrok &> /dev/null
then
  echo ngrok is not installed.
  echo Visit https://ngrok.com/download and download the version for your OS.
  exit 1
fi

if ! command -v jq &> /dev/null
then
  echo jq is not installed.
  echo Visit https://stedolan.github.io/jq/download/ and download the version for your OS.
  echo If you have one, you can usually use your package manager to install it.
  exit 2
fi

if [ -z "$MODIG_NGROK_FULL_URL" ]; then
    # Get the https url from lando
    MODIG_NGROK_FULL_URL=$(lando info --format json | jq '.[0].urls[3]' | tr '"' ' ')
fi


#
# Strip off the protocol
#
MODIG_NGROK_URL=$(echo "$MODIG_NGROK_FULL_URL" | awk -F '//' '{print $2}')
MODIG_NGROK_URL=${MODIG_NGROK_URL::-1}

#
# Call ngrok
#
echo "Staring ngrok for $MODIG_NGROK_URL with name $MODIG_NGROK_FULL_URL"
ngrok http --host-header="$MODIG_NGROK_URL" "$MODIG_NGROK_FULL_URL" > /dev/null &


# Give ngrok a few seconds to initialize
sleep 2

# Extract protocol (http or https)
protocol=$(echo "$MODIG_NGROK_FULL_URL" | grep -oE '^(http|https)')

# Check if URL contains a port
if [[ ! "$MODIG_NGROK_FULL_URL" =~ :[0-9]+ ]]; then
    # No port found, add default port based on protocol
    if [[ "$protocol" == "http" ]]; then
        MODIG_NGROK_FULL_URL="${MODIG_NGROK_FULL_URL}:80"
    elif [[ "$protocol" == "https" ]]; then
        MODIG_NGROK_FULL_URL="${MODIG_NGROK_FULL_URL}:443"
    fi
fi

# Filter tunnels to find one with the ConfigAddr matching MODIG_NGROK_FULL_URL and get its public_url
# shellcheck disable=SC2034
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r --arg url "$MODIG_NGROK_FULL_URL" '.tunnels[] | select(.config.addr == $url) | .public_url | select(.!=null) | .')

execute_part "config-ngrok"
