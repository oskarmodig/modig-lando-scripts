#!/bin/bash

# Function to add strict_types declaration to a PHP file if it doesn't exist.
add_strict_types_to_file() {
    local file_path="$1"
    local content
    content=$(cat "$file_path")

    if ! grep -q 'declare(strict_types=1);' <<< "$content"; then
        # Check if there is a file docblock
        if [[ "$content" =~ ^\(\<\?php[[:space:]]*\/\*\*.*\*\/[[:space:]]*\) ]]; then
            docblock="${BASH_REMATCH[0]}"
            rest_of_content="${content:${#docblock}}"
            updated_content="${docblock}declare(strict_types=1);\n\n${rest_of_content}"
        else
            rest_of_content="${content#<?php}"
            updated_content="<?php\ndeclare(strict_types=1);\n\n${rest_of_content}"
        fi
        echo -e "$updated_content" > "$file_path"
        echo "Added strict_types to: $file_path"
    fi
}

# Function to iterate over all PHP files in a directory and apply the strict_types declaration
add_strict_types_to_directory() {
    local dir="$1"
    local excluded_dirs=("${@:2}")

    while IFS= read -r -d '' file; do
        # Check if file is in an excluded directory
        skip=false
        for excluded_dir in "${excluded_dirs[@]}"; do
            if [[ "$file" == *"$excluded_dir"* ]]; then
                skip=true
                break
            fi
        done

        if ! $skip && [[ "$file" == *.php ]]; then
            add_strict_types_to_file "$file"
        fi
    done < <(find "$dir" -type f -name "*.php" -print0)
}

# Set the path to your project directory
excluded_dirs=("wordpress" "vendor" "node_modules" "deploy" "testsuite")

# Run the script
add_strict_types_to_directory "$MOD_VAR_PACKAGE_PATH" "${excluded_dirs[@]}"
