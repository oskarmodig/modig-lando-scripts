#!/bin/bash

echo_progress "Running 'composer update' after removing online-shared vendor dir"
rm -rf vendor/northmill/online-shared

composer update

echo_progress "Running 'composer scoper-prefix'"
rm -rf online-shared
composer scoper-prefix
