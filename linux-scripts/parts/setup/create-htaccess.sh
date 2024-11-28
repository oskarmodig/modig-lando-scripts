#!/bin/bash

create_htaccess() {
  local htaccess_path
  htaccess_path="$MOD_LOC_ABSOLUT_WP_PATH/.htaccess"

  # Check if the WordPress site is a multisite
  call_wp_without_retry core is-installed --network
  exit_status=$?

  if [ $exit_status -eq 0 ]; then
    # Check if the multisite is using subdomains
    call_wp_without_retry network meta get 1 subdomain_install --format=plaintext
    subdomain_status=$?

    if [ $subdomain_status -eq 0 ]; then
      # Commands for multisite with subdomains .htaccess
      echo "Creating .htaccess for a multisite installation with subdomains..."
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
      # Commands for multisite with subdirectories .htaccess
      echo "Creating .htaccess for a multisite installation with subdirectories..."
      echo "# BEGIN WordPress Multisite

RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]

# add a trailing slash to /wp-admin
RewriteRule ^([_0-9a-zA-Z-]+/)?wp-admin$ \$1wp-admin/ [R=301,L]

RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]
RewriteRule ^([_0-9a-zA-Z-]+/)?(wp-(content|admin|includes).*) \$2 [L]
RewriteRule ^([_0-9a-zA-Z-]+/)?(.*\.php)$ \$2 [L]
RewriteRule . index.php [L]

# END WordPress Multisite" | lando ssh -c "cat > $htaccess_path"
    fi
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
