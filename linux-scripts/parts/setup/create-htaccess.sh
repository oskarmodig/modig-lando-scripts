#!/bin/bash

create_htaccess() {
  local htaccess_path
  htaccess_path="$MOD_LOC_ABSOLUT_WP_PATH/.htaccess"

  # Check if the WordPress site is a multisite
  call_wp_without_retry core is-installed --network
  exit_status=$?

  if [ $exit_status -eq 0 ]; then
    # Commands for multisite .htaccess
    echo "Creating .htaccess for a multisite installation..."
    echo "# BEGIN WordPress
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
# END WordPress" | lando ssh -c "cat > $htaccess_path"
  else
    # Commands for single site .htaccess
    echo "Creating .htaccess for a single-site installation..."
    echo "# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress" | lando ssh -c "cat > $htaccess_path"
  fi
}

create_htaccess
