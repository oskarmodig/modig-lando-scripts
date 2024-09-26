# Run composer update both on local machine and in the container
composer update

# If composer script "scoper-prefix" exists, run it
if [ -f "composer.json" ] && [ -n "$(jq -r '.scripts."scoper-prefix"' composer.json)" ]; then
    echo_progress "Running 'composer scoper-prefix'"
    composer scoper-prefix
fi

lando composer update
