#!/bin/bash

# Start lando
lando start

# Build lando
execute_part "install-wordpress"

# Create .htaccess file with contents
execute_part "create-htaccess"

# Create an empty debug.log file
touch "/$MOD_LOC_WORDPRESS_PATH/wp-content/debug.log"
