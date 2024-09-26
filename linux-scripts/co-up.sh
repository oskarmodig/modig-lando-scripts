# Run composer update both on local machine and in the container
composer update

# If composer script "add-prefix" exists, run it
if [ -f "composer.json" ] && [ -n "$(jq -r '.scripts."add-prefix"' composer.json)" ]; then
    echo_progress "Running 'composer add-prefix'"
    composer add-prefix
fi

lando composer update
