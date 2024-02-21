#!/bin/bash

call_wp_without_retry() {
    local wordpress_path
    wordpress_path="MOD_VAR_PACKAGE_PATH/MOD_VAR_WP_PATH"
    lando wp "$@" --path="$wordpress_path"
}

call_wp() {
    local wordpress_path
    wordpress_path="MOD_VAR_PACKAGE_PATH/MOD_VAR_WP_PATH"

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
