#!/bin/bash

# Comment out lando excludes
#execute_part "excludes-disable"

# Start lando
lando start

# Build lando
execute_part "install-wordpress"

# Create .htaccess file with contents
execute_part "create-htaccess"

# Create an empty debug.log file
touch "/$MOD_LOC_WORDPRESS_PATH/wp-content/debug.log"

# Restore lando excludes
#execute_part "excludes-re-enable"
# TODO: The rebuilding after this does not seem to include the "excludes". What can we do about this? Maybe wait/pause?

# Rebuild lando
lando rebuild -y
