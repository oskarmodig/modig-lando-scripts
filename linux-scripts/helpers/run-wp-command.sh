#!/bin/bash

call_wp_without_retry() {
    lando wp "$@" --path=wordpress
}

call_wp() {
  echo "Running command: wp $*"

    echo_progress Running WP command: wp "$@"
    while true; do
        lando wp "$@" --path=wordpress
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
