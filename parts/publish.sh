#!/bin/bash

# Script for deploying files to a remote server

change_dir "$MOD_VAR_PACKAGE_PATH" "Package path not found."

# Check for the MOD_VAR_DLF variable and set MOD_VAR_FILE_1 to its value if it is set
if [ -n "$MOD_VAR_DLF" ]; then
  # Add -test to the file name if MOD_INP_TEST is set, prepping for publish.
    if [ -n "$MOD_INP_TEST" ]; then
        MOD_VAR_DLF="$MOD_VAR_DLF-test"
    fi
    MOD_VAR_FILE_1="$MOD_VAR_DLF"
fi

# Check for required variables
if [ -z "$MOD_VAR_VER" ] || [ -z "$MOD_VAR_REMOTE_HOST" ] || [ -z "$MOD_VAR_FILE_1" ] || [ -z "$MOD_VAR_TARGET_USER" ] || [ -z "$MOD_VAR_TARGET_GROUP" ]; then
    exit_script "You have to set MOD_VAR_VER, MOD_VAR_REMOTE_HOST, MOD_VAR_FILE_1, MOD_VAR_TARGET_USER, and MOD_VAR_TARGET_GROUP"
fi

# Default values
MOD_VAR_REMOTE_USER=${MOD_VAR_REMOTE_USER:-"ubuntu"}
MOD_VAR_CERT_FILE=${MOD_VAR_CERT_FILE:-"cert.pem"}
MOD_VAR_CERT_PATH=${MOD_VAR_CERT_PATH:-"/lando/ssh"}
MOD_VAR_FILE_2=${MOD_VAR_FILE_2:-""}
MOD_VAR_TARGET_DIR=${MOD_VAR_TARGET_DIR:-"/var/www/publishing_test/public_html/plugin"}

# Set the local directory based on the package version
LOCAL_DIR="./deploy/v$MOD_VAR_VER/downloadsflo"

# Check if MOD_VAR_FILE_2 is not set and MOD_VAR_FILE_1 has no extension
if [[ -z "$MOD_VAR_FILE_2" && ! "$MOD_VAR_FILE_1" =~ \..+$ ]]; then
    MOD_VAR_FILE_2="$MOD_VAR_FILE_1.json"
    MOD_VAR_FILE_1="$MOD_VAR_FILE_1.zip"
fi

# Create the archive file name if MOD_VAR_ARCHIVE_FILE is set
if [[ -n "$MOD_VAR_ARCHIVE_FILE" ]]; then
    MOD_VAR_ARCHIVE_FILE="${MOD_VAR_FILE_1%.*}_v$MOD_VAR_VER.${MOD_VAR_FILE_1##*.}"
fi

# Derive full paths for the files using LOCAL_DIR
MOD_VAR_FILE_1="$LOCAL_DIR/$MOD_VAR_FILE_1"
MOD_VAR_FILE_2="$LOCAL_DIR/$MOD_VAR_FILE_2"
MOD_VAR_CERT_PATH="$MOD_VAR_CERT_PATH/$MOD_VAR_CERT_FILE"

# Function to perform the SCP transfer
perform_scp_transfer() {
    scp -i "$MOD_VAR_CERT_PATH" "$MOD_VAR_FILE_1" "$MOD_VAR_FILE_2" "$MOD_VAR_REMOTE_USER@$MOD_VAR_REMOTE_HOST":~
}

# Copy files to remote server using scp with retry mechanism
while true; do
    echo "Copying files to remote server..."
    perform_scp_transfer

    if [[ $? -eq 0 ]]; then
        echo "Files copied successfully!"
        break
    else
        echo "Failed to copy files."
        read -rp "Do you want to retry? (y/n): " retry_choice
        if [[ $retry_choice != [Yy] ]]; then
            exit_script "SCP transfer aborted."
        fi
    fi
done

# 2. Log in to the same server over ssh and execute subsequent commands
ssh -i "$MOD_VAR_CERT_PATH" "$MOD_VAR_REMOTE_USER@$MOD_VAR_REMOTE_HOST" << ENDSSH
    # Define variables directly
    MOD_VAR_FILE_1='${MOD_VAR_FILE_1##*/}'
    MOD_VAR_FILE_2='${MOD_VAR_FILE_2##*/}'
    MOD_VAR_TARGET_DIR='$MOD_VAR_TARGET_DIR'
    MOD_VAR_TARGET_USER='$MOD_VAR_TARGET_USER'
    MOD_VAR_TARGET_GROUP='$MOD_VAR_TARGET_GROUP'
    MOD_VAR_ARCHIVE_FILE='${MOD_VAR_ARCHIVE_FILE##*/}'

    # Define the remote_file_operation function
    remote_file_operation() {
        local operation="\$1"
        local source="\$2"
        local destination="\$3"
        local options="\$4"

        if [[ -n "\$options" ]]; then
            sudo "\$operation" "\$options" "\$source" "\$destination"
        else
            sudo "\$operation" "\$source" "\$destination"
        fi

        if [[ \$? -ne 0 ]]; then
            echo "Error in \$operation operation for \$source"
            exit 1
        fi
    }

    # Copy (and replace) the files from user's home to the target directory
    echo "Copying files to target directory..."
    remote_file_operation "cp" "\$HOME/\$MOD_VAR_FILE_1" "\$MOD_VAR_TARGET_DIR/"
    remote_file_operation "cp" "\$HOME/\$MOD_VAR_FILE_2" "\$MOD_VAR_TARGET_DIR/"

    # Change permissions of the files to 770
    echo "Changing file permissions..."
    remote_file_operation "chmod" "770" "\$MOD_VAR_TARGET_DIR/\$MOD_VAR_FILE_1"
    remote_file_operation "chmod" "770" "\$MOD_VAR_TARGET_DIR/\$MOD_VAR_FILE_2"

    # Change the owner of the files
    echo "Changing file owner and group..."
    remote_file_operation "chown" "\$MOD_VAR_TARGET_USER:\$MOD_VAR_TARGET_GROUP" "\$MOD_VAR_TARGET_DIR/\$MOD_VAR_FILE_1"
    remote_file_operation "chown" "\$MOD_VAR_TARGET_USER:\$MOD_VAR_TARGET_GROUP" "\$MOD_VAR_TARGET_DIR/\$MOD_VAR_FILE_2"

    # Handling archive files if necessary
    if [[ -n "\$MOD_VAR_ARCHIVE_FILE" ]]; then
        echo "Archiving file to version_history directory..."
        sudo mkdir -p "\$MOD_VAR_TARGET_DIR/version_history"
        remote_file_operation "cp" "\$HOME/\$MOD_VAR_FILE_1" "\$MOD_VAR_TARGET_DIR/version_history/\$MOD_VAR_ARCHIVE_FILE"
        remote_file_operation "chmod" "770" "\$MOD_VAR_TARGET_DIR/version_history/\$MOD_VAR_ARCHIVE_FILE"
        remote_file_operation "chown" "\$MOD_VAR_TARGET_USER:\$MOD_VAR_TARGET_GROUP" "\$MOD_VAR_TARGET_DIR/version_history/\$MOD_VAR_ARCHIVE_FILE"
    fi

    echo "All tasks completed!"
ENDSSH



if [[ $? -ne 0 ]]; then
    exit_script "Failed to execute remote commands."
fi

echo "Script execution completed successfully!"
