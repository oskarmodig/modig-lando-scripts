#!/bin/bash

# Start lando
lando start

# Build lando
execute_part "install-wordpress"

echo_progress "Creating symlink for package"
lando mount

# Create an empty debug.log file
touch "/$MOD_LOC_WORDPRESS_PATH/wp-content/debug.log"

# Create .htaccess file with contents
# execute_part "create-htaccess" # TODO: This is not loading

# Check if the WordPress site is a multisite
call_wp_without_retry core is-installed --network
exit_status=$?

if [ $exit_status -eq 0 ]; then
    # If it is a multisite, create .htaccess with multisite content
    # Replace this with either subdirectory or subdomain content as needed
    cat <<EOM > "$MOD_LOC_WORDPRESS_PATH/.htaccess"
# BEGIN WordPress
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
# add a trailing slash to /wp-admin
RewriteRule ^wp-admin$ wp-admin/ [R=301,L]
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]
RewriteRule ^(wp-(content|admin|includes).*) \$1 [L]
RewriteRule ^(.*\.php)$ \$1 [L]
RewriteRule . index.php [L]
# END WordPress
EOM
else
    # If it is not a multisite, create .htaccess with standard content
    cat <<EOM > "$MOD_LOC_WORDPRESS_PATH/.htaccess"
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOM
fi

# Stop lando (since the port is most likely incorrect
lando stop

echo_progress "Lando setup complete! You can now start lando with 'lando start' and access your site at http://$MOD_LOC_LANDO_APP_NAME.lndo.site"
