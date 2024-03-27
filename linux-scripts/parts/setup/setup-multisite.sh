echo_progress "Set up multisite"
call_wp core multisite-install --subdomains --title="$MOD_LOC_LANDO_APP_NAME DEV" --admin_user="admin" --admin_password="password" --admin_email="user@example.com"
