#!/bin/bash

echo_progress "Removing WordPress folder"
rm -rf wordpress

echo_progress "Destroying lando app"
lando destroy -y
