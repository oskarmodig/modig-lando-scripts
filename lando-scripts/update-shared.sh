#!/bin/bash

echo_progress "Running 'composer update' after removing online-shared vendor dir"
rm -rf vendor/northmill/online-shared

composer update

echo_progress "Running 'composer scoper-prefix'"
rm -rf online-shared
rm -rf /tmp/northmill-online-shared
composer scoper-prefix

echo_progress "Moving online shared from temp dir"
mv /tmp/northmill-online-shared online-shared
