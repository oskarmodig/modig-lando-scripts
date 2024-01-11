#!/bin/bash

# Process .lando.yml to extract .env file paths and store them in a temporary file
awk '/^env_file:/{flag=1;next}flag && /^  - /{sub(/^  - /, ""); print $0}flag && /^[a-zA-Z_]+:/{flag=0}' "$MOD_LOC_LANDO_FILE" > temp_env_paths.txt

# Remove potential carriage return characters
sed -i 's/\r$//' temp_env_paths.txt

# Read each line from the temporary file
while IFS= read -r ENV_FILE; do
    FULL_PATH="$MOD_LOC_SCRIPT_CALLED_FROM/$ENV_FILE"
    TEMP_PATH="/tmp/temp_env_file.env"
    echo_progress "$FULL_PATH"

    if [ -f "$FULL_PATH" ]; then
        # Copy to a temporary file
        cp "$FULL_PATH" "$TEMP_PATH"

        # Convert Windows line endings (CRLF) to Unix line endings (LF) using sed
        sed -i 's/\r$//' "$TEMP_PATH"

        set -a  # Automatically export all variables
        # shellcheck disable=SC1090
        source "$TEMP_PATH"
        set +a  # Disable auto-export

        # Clean up the temporary .env file
        rm "$TEMP_PATH"
    else
        echo "Warning: .env file '$FULL_PATH' not found."
        exit 1;
    fi
done < temp_env_paths.txt

# Clean up the temporary file with paths
rm temp_env_paths.txt
