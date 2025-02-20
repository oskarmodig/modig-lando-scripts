#!/bin/bash

change_dir "$MOD_VAR_PACKAGE_PATH" "Package path not found."

# Set up the temporary directory
MOD_LOC_TEMP_DIR_NAME=$MOD_VAR_PACKAGE_NAME

if [ -n "$MOD_INP_TEST" ]; then
    MOD_LOC_TEMP_DIR_NAME="$MOD_LOC_TEMP_DIR_NAME-test"
fi

# Remove existing deploy directory, and create the temporary directory for the package

if [ -n "$MOD_INP_TEST" ]; then
    MOD_LOC_DESTINATION_DIR="$MOD_VAR_PACKAGE_PATH/deploy/test/v$MOD_LOC_PACKAGE_VER"
else
    MOD_LOC_DESTINATION_DIR="$MOD_VAR_PACKAGE_PATH/deploy/v$MOD_LOC_PACKAGE_VER"
fi

TMP_DIR_BASE="/tmp/lando_build"
TMP_DIR="$TMP_DIR_BASE/$MOD_LOC_TEMP_DIR_NAME"

echo_progress "Preparing for deployment"
remove_dir "$MOD_LOC_DESTINATION_DIR"
create_dir "$TMP_DIR"

# Define and execute rsync options to copy files to the temporary directory
# The script excludes certain files and directories from being copied
# NOTE, if something is added to this list, it should also be added to the list in the readme file.
rsync_options=(
    -av
    --exclude="/*.sql"
    --exclude="/*.sql.gz"
    --exclude="/.*"
    --exclude="/*.env"
    --exclude /node_modules
    --exclude /wordpress
    --exclude /testsuite
    --exclude /tests
    --exclude /bin
    --exclude /deploy
    --exclude /customization-plugins
    --exclude "*.gitlab-ci.yml*"
    --exclude "*.git*"
    --exclude "*.DS_Store*"
    --exclude /vendor
    --exclude "phpunit.xml.dist"
    --exclude "scoper.inc.php"
    --exclude /online-shared/php-scoper-helpers
)

if [ -n "$MOD_VAR_EXTRA_EXCLUDES" ]; then
    IFS=',' read -ra EXTRA_EXCLUDES <<< "$MOD_VAR_EXTRA_EXCLUDES"
    for item in "${EXTRA_EXCLUDES[@]}"; do
        rsync_options+=( --exclude "$item" )
    done
fi

rsync "${rsync_options[@]}" . "$TMP_DIR"

change_dir "$TMP_DIR" "Could not enter inner temporary directory."

# Run composer operations if $MOD_VAR_SKIP_COMPOSER is not set, and composer.json exist.
if [ -f "composer.json" ] && [ -z "$MOD_VAR_SKIP_COMPOSER" ]; then
    echo_progress "Running 'composer install --no-dev --optimize-autoloader'"
    composer install --no-dev --optimize-autoloader
fi

# Run npm operations if $MOD_VAR_SKIP_NPM is not set, and package.json exist.
if command_exists npm && [ -f "package.json" ] && [ -z "$MOD_VAR_SKIP_NPM" ]; then
  #Check if a build script is defined in the package.json file
  if [ -n "$(jq -r '.scripts.build' package.json)" ]; then
    echo_progress "Running 'npm ci'"
    npm ci
    echo_progress "Running 'npm run build'"
    npm run build
  fi
else
  echo_notice "npm not found or package.json not found, skipping npm operations."
fi

if [ -n "$MOD_VAR_REMOVE_DIR_AFTER_BUILD" ]; then
    IFS=',' read -ra REMOVE_DIR_AFTER_BUILD <<< "$MOD_VAR_REMOVE_DIR_AFTER_BUILD"
    for item in "${REMOVE_DIR_AFTER_BUILD[@]}"; do
        remove_dir "$item"
    done
fi

if [ -n "$MOD_VAR_REMOVE_FILES_AFTER_BUILD" ]; then
    IFS=',' read -ra REMOVE_FILES_AFTER_BUILD <<< "$MOD_VAR_REMOVE_FILES_AFTER_BUILD"
    for item in "${REMOVE_FILES_AFTER_BUILD[@]}"; do
        rm "$item"
    done
fi

rm -rf node_modules
rm -f composer.json -f
rm -f composer.lock -f
rm -f package.json -f
rm -f package-lock.json -f
rm -f webpack.config.js -f
rm -f babel.config.json -f

rm -rf "vendor/northmill/online-shared/.git"
rm -rf "vendor/northmill/online-shared/php-scoper-helpers"
rm -f "vendor/northmill/online-shared/.gitattributes"
rm -f "vendor/northmill/online-shared/.gitignore"
rm -f "vendor/northmill/online-shared/.lando.public.env"
rm -f "vendor/northmill/online-shared/.lando.secret.example.env"
rm -f "vendor/northmill/online-shared/.lando.yml"
rm -f "vendor/northmill/online-shared/composer.json"
rm -f "vendor/northmill/online-shared/composer.lock"
rm -f "vendor/northmill/online-shared/README.md"
find "vendor/northmill/online-shared" -type f -name "*.php" -exec rm -f {} +
find "vendor/northmill/online-shared" -type d -empty -delete

# TODO: Update to work with themes
if [ -n "$MOD_INP_TEST" ]; then
  # IF MOD_VAR_PACKAGE_TYPE = plugin
  if [ "$MOD_VAR_PACKAGE_TYPE" = "plugin" ]; then
    PLUGIN_FILE=$(find_main_plugin_file ".")
    if [[ -z "$PLUGIN_FILE" ]]; then
        echo "No main plugin file found."
        exit 1
    fi
    # Prepend "TEST - " to the plugin name
    sed -i 's/\(Plugin Name: \)/\1TEST - /' "$PLUGIN_FILE"
  elif [ "$MOD_VAR_PACKAGE_TYPE" = "theme" ]; then
    THEME_FILE=$(find_main_theme_file ".")
    if [[ -z "$THEME_FILE" ]]; then
        echo "No main theme file found."
        exit 1
    fi
    # Prepend "TEST - " to the theme name
    sed -i 's/\(Theme Name: \)/\1TEST - /' "$THEME_FILE"
  fi
fi

cd ..

# Function to create a zip file
create_zip() {
    local base_name="$1"       # Name of the zip file and the source directory inside

    local source_dir="$MOD_LOC_TEMP_DIR_NAME"                # Source directory to zip
    local json_destination_name="$MOD_VAR_PACKAGE_NAME.json" # Name of the destination JSON file

    if [ -n "$MOD_INP_TEST" ]; then
        base_name="$base_name-test"
        json_destination_name="$MOD_VAR_PACKAGE_NAME-test.json"
    fi

    # Rename $source_dir if not already named as base_name
    if [ "$source_dir" != "$base_name" ]; then
        mv "$source_dir" "$base_name"
        source_dir="$base_name"
    fi

    echo_progress "Creating $base_name zip package"

    zip -r "$(basename "$base_name")".zip "$source_dir"

    move_dir="$MOD_LOC_DESTINATION_DIR"

    # Move the zip file to its destination
    create_dir "$move_dir"
    base_name_zip="$(basename "$base_name").zip"
    if ! mv "$base_name_zip" "$move_dir"; then
        exit_script "Error: Failed to move '$base_name_zip' to '$move_dir'"
    fi

    if [ -n "$MOD_VAR_PUBLISH" ]; then
      # Handle JSON file if exists

      json_file="$source_dir/$MOD_VAR_PACKAGE_NAME.json"
      if [[ -f "$json_file" ]]; then
        cp "$json_file" "$move_dir/$json_destination_name"

        # shellcheck disable=SC2034
        MOD_LOC_SKIP_PUBLISH=false #Enables running publish script after this.
      else
        echo_notice "JSON file not found: $json_file"
      fi
    fi

    # Rename $MOD_LOC_TEMP_DIR_NAME back to its original name, for any further zip creations.
    if [ "$MOD_LOC_TEMP_DIR_NAME" != "$base_name" ]; then
        mv "$base_name" "$MOD_LOC_TEMP_DIR_NAME"
    fi
}

# Always create main zip file for WP
create_zip "$MOD_VAR_PACKAGE_NAME"

# Clean up by removing the temporary directory
echo_progress "Removing TEMP DIR"
remove_dir "$TMP_DIR_BASE"

# Final message indicating the completion of the deployment process
echo_progress "Deploy finished"
