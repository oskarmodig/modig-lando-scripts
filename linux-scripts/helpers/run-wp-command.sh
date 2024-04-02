#!/bin/bash

echo_wp_path() {
    local wordpress_path
    if [ -n "$MOD_VAR_WP_PATH" ]; then
        wordpress_path="$MOD_VAR_PACKAGE_PATH/$MOD_VAR_WP_PATH"
    elif [ -n "$MODIG_WP_PATH" ]; then
        wordpress_path="$MODIG_WP_PATH"
    else
        wordpress_path="wordpress"
    fi
    echo "$wordpress_path"
}

call_wp_without_retry() {
    local wordpress_path
    wordpress_path=$( echo_wp_path )
    lando wp "$@" --path="$wordpress_path"
}

call_wp() {
    local wordpress_path
    wordpress_path=$( echo_wp_path )

    echo_progress "Running WP command: wp $* in $wordpress_path"
    while true; do
        lando wp "$@" --path="$wordpress_path"
        local exit_status=$?

        if [[ $exit_status -eq 0 ]]; then
            # Command succeeded, exit the loop
            return 0
        else
            # Command failed, ask the user if they want to retry
            read -r -p "Command failed. Do you want to retry? (y/n): " retry_answer
            case $retry_answer in
                [Yy]* ) continue;;  # Continue the loop, thus retrying the command
                * )
                    echo "Aborting..."
                    return $exit_status;;  # Exit the function with the command's exit status
            esac
        fi
    done
}
