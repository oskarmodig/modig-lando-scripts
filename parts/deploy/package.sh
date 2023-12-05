#!/bin/bash

change_dir "$MOD_VAR_PACKAGE_PATH" "Package path not found."

# Set up the temporary directory
MOD_LOC_TEMP_DIR=$MOD_VAR_MAIN_WP_NAME

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

# Run composer operations if specified
if [ -n "$MOD_VAR_RUN_COMPOSER" ]; then
    handle_composer
    unset MOD_VAR_SKIP_VENDOR
fi

# Define and execute rsync options to copy files to the temporary directory
# The script excludes certain files and directories from being copied
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
    --exclude "composer.json"
    --exclude "composer.lock"
    --exclude "babel.config.json"
    --exclude "webpack.config.js"
    --exclude "package.json"
    --exclude "package-lock.json"
    --exclude "phpunit.xml.dist"
)
if [ -z "$MOD_VAR_SKIP_VENDOR" ]; then
    rsync_options+=( --exclude /vendor )
fi
rsync "${rsync_options[@]}" . "deploy/_tmp/$MOD_LOC_TEMP_DIR"
change_dir "deploy/_tmp" "Temporary directory not found." true

# Function to create a zip file
create_zip() {
    local base_name="$1"       # Name of the zip file, and the source directory inside if include_dir is true
    local destination_dir="$2" # Destination directory to move the zip file, inside deploy folder
    local include_dir="$3"     # Whether to include the source directory in the zip file (or just the contents)
    local copy_json="$4"       # Whether to copy the JSON file

    local source_dir="$MOD_LOC_TEMP_DIR"                     # Source directory to zip
    local json_destination_name="$MOD_VAR_JSON.json" # Name of the destination JSON file

    if [ -n "$MOD_INP_TEST" ]; then
        base_name="$base_name-test"
        json_destination_name="$MOD_VAR_JSON-test.json"
    fi

    # Rename $MOD_LOC_TEMP_DIR if not already named as base_name
    if [ "$MOD_LOC_TEMP_DIR" != "$base_name" ]; then
        mv "$MOD_LOC_TEMP_DIR" "$base_name"
        source_dir="$base_name"
    fi

    echo_progress "Creating file for $destination_dir"

    # Save the current directory
    local original_dir
    original_dir=$(pwd)

    if [ "$include_dir" = false ]; then
        change_dir "$source_dir" "Source dir not found."
        zip -r "$(basename "$base_name")".zip .
    else
        zip -r "$(basename "$base_name")".zip "$source_dir"
    fi

    move_dir="$MOD_LOC_DESTINATION_DIR/$destination_dir"

    # Move the zip file to its destination
    create_dir "$move_dir"
    mv "$(basename "$base_name")".zip "$move_dir"

    # Return to the original directory
    change_dir "$original_dir" "Original dir not found."

    if [ "$copy_json" = true ]; then
      # Handle JSON file if exists
      MOD_VAR_JSON=${MOD_VAR_JSON:-"info"}

      json_file="$source_dir/$MOD_VAR_JSON.json"
      if [[ -f "$json_file" ]]; then
        cp "$json_file" "$move_dir/$json_destination_name"
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
create_zip "$MOD_VAR_MAIN_WP_NAME" "wp" true false

# Maybe create zip files for downloadsflo,
if [ -n "$MOD_VAR_DLF_NAME" ]; then
    create_zip "$MOD_VAR_DLF_NAME" "downloadsflo" false true
    # shellcheck disable=SC2034
    MOD_LOC_SKIP_PUBLISH=false #Enables running publish script after this.
else
    echo_notice "Skip creating file for downloadsflo"
fi

change_dir "deploy" "Temporary directory not found." true

# Clean up by removing the temporary directory
echo_progress "Removing TEMP DIR"
remove_dir "_tmp"

# Final composer handling if required
if [ -n "$MOD_VAR_RUN_COMPOSER" ]; then
    handle_composer true
fi

# Final message indicating the completion of the deployment process
echo_progress "Deploy finished"
