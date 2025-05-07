#!/bin/bash

echo_progress "Removing current online-shared vendor dir"
rm -rf vendor/northmill/online-shared

echo_progress "Running 'composer install'"
composer install

echo_progress "Removing any /tmp/northmill-online-shared project dir"
rm -rf /tmp/northmill-online-shared

echo_progress "Running 'composer scoper-prefix'"
composer scoper-prefix

echo_progress "Removing current online-shared project dir"
rm -rf online-shared

echo_progress "Moving online shared from temp dir"
mv /tmp/northmill-online-shared online-shared
