# Run composer update both on local machine and in the container
composer update

# If composer script "scoper-prefix" exists, run it
if [ -f "composer.json" ] && [ -n "$(jq -r '.scripts."scoper-prefix"' composer.json)" ]; then
    echo_progress "Running 'composer scoper-prefix'"
    rm -rf online-shared
    composer scoper-prefix
fi

lando composer update
