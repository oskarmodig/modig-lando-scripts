#!/bin/bash

# Check if the WordPress site is a multisite
if wp core is-installed --network; then
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
RewriteRule ^(wp-(content|admin|includes).*) $1 [L]
RewriteRule ^(.*\.php)$ $1 [L]
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
