# Run composer update both on local machine and in the container
composer update

# If composer script "scoper-prefix" exists, run it
if [ -f "composer.json" ] && [ -n "$(jq -r '.scripts."scoper-prefix"' composer.json)" ]; then
    echo_progress "Running 'composer scoper-prefix'"
    rm -rf online-shared
    composer scoper-prefix

    echo_progress "Removing php files from online-shared vendor dir"
    find "vendor/northmill/online-shared" -type f -name "*.php" -exec rm -f {} +
    find "vendor/northmill/online-shared" -type d -empty -delete
fi

lando composer install
