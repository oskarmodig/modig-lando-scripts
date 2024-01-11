#!/bin/bash

# Comment out lando excludes
execute_part "excludes-disable"

# Start lando
lando start

# Build lando
execute_part "install-wordpress"

# Create .htaccess file with contents
execute_part "htaccess"

# Create an empty debug.log file
touch "/$MOD_LOC_WORDPRESS_PATH/wp-content/debug.log"

# Restore lando excludes
execute_part "excludes-disable"

# Rebuild lando
lando rebuild -y
