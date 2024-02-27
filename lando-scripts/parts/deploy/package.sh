#!/bin/bash

change_dir "$MOD_VAR_PACKAGE_PATH" "Package path not found."

# Set up the temporary directory
MOD_LOC_TEMP_DIR=$MOD_VAR_PACKAGE_NAME

if [ -n "$MOD_INP_TEST" ]; then
    MOD_LOC_TEMP_DIR="$MOD_LOC_TEMP_DIR-test"
fi

# Remove existing deploy directory, and create the temporary directory for the package

if [ -n "$MOD_INP_TEST" ]; then
    MOD_LOC_DESTINATION_DIR="$MOD_VAR_PACKAGE_PATH/deploy/test/v$MOD_LOC_PACKAGE_VER"
else
    MOD_LOC_DESTINATION_DIR="$MOD_VAR_PACKAGE_PATH/deploy/v$MOD_LOC_PACKAGE_VER"
fi

echo_progress "Preparing for deployment"
remove_dir "$MOD_LOC_DESTINATION_DIR"
create_dir "deploy/_tmp/$MOD_LOC_TEMP_DIR"

# Define and execute rsync options to copy files to the temporary directory
# The script excludes certain files and directories from being copied
# NOTE, if something is added to this list, it should also be added to the list in the readme file.
rsync_options=(
    -av
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
    --exclude "babel.config.json"
    --exclude "webpack.config.js"
    --exclude "phpunit.xml.dist"
)

if [ -n "$MOD_VAR_EXTRA_EXCLUDES" ]; then
    IFS=',' read -ra EXTRA_EXCLUDES <<< "$MOD_VAR_EXTRA_EXCLUDES"
    for item in "${EXTRA_EXCLUDES[@]}"; do
        rsync_options+=( --exclude "$item" )
    done
fi

rsync "${rsync_options[@]}" . "deploy/_tmp/$MOD_LOC_TEMP_DIR"
change_dir "deploy/_tmp" "Temporary directory not found." true

# Run composer operations if $MOD_VAR_SKIP_COMPOSER is not set, and composer.json exist.
if [ -f "$MOD_LOC_TEMP_DIR/composer.json" ]; then
  change_dir "$MOD_LOC_TEMP_DIR" "Could not enter inner temporary directory."
  if [ -z "$MOD_VAR_SKIP_COMPOSER" ]; then
      composer install --no-dev --optimize-autoloader
  fi
  rm composer.json
  rm composer.lock
  cd ..
fi

# Run npm operations if $MOD_VAR_SKIP_NPM is not set, and package.json exist.
if [ -f "$MOD_LOC_TEMP_DIR/package.json" ]; then
  change_dir "$MOD_LOC_TEMP_DIR" "Could not enter inner temporary directory."
  if [ -z "$MOD_VAR_SKIP_NPM" ]; then
      npm install && npm run build
  fi
  rm package.json
  rm package-lock.json
  cd ..
fi

if [ -n "$MOD_VAR_REMOVE_DIR_AFTER_BUILD" ]; then
    IFS=',' read -ra REMOVE_DIR_AFTER_BUILD <<< "$MOD_VAR_REMOVE_DIR_AFTER_BUILD"
    for item in "${REMOVE_DIR_AFTER_BUILD[@]}"; do
        remove_dir "$MOD_LOC_TEMP_DIR/$item"
    done
fi

# Function to create a zip file
create_zip() {
    local base_name="$1"       # Name of the zip file, and the source directory inside if include_dir is true

    local source_dir="$MOD_LOC_TEMP_DIR"                     # Source directory to zip
    local json_destination_name="$MOD_VAR_PACKAGE_NAME.json" # Name of the destination JSON file

    if [ -n "$MOD_INP_TEST" ]; then
        base_name="$base_name-test"
        json_destination_name="$MOD_VAR_PACKAGE_NAME-test.json"
    fi

    # Rename $MOD_LOC_TEMP_DIR if not already named as base_name
    if [ "$MOD_LOC_TEMP_DIR" != "$base_name" ]; then
        mv "$MOD_LOC_TEMP_DIR" "$base_name"
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

    # Rename $MOD_LOC_TEMP_DIR back to its original name
    if [ "$MOD_LOC_TEMP_DIR" != "$base_name" ]; then
        mv "$base_name" "$MOD_LOC_TEMP_DIR"
    fi
}

# Always create main zip file for WP
create_zip "$MOD_VAR_PACKAGE_NAME"

change_dir "deploy" "Temporary directory not found." true

# Clean up by removing the temporary directory
echo_progress "Removing TEMP DIR"
remove_dir "_tmp"

# Final message indicating the completion of the deployment process
echo_progress "Deploy finished"
