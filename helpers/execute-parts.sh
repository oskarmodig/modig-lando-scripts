#!/bin/bash

execute_part() {
    # Replace dashes with underscores part name, and make it uppercase
    local part_name="$1"
    part_name=${part_name//-/_}
    part_name=${part_name^^}

    local var_name="MOD_LOC_SKIP_$part_name"

    # if variable MOD_LOC_SKIP_[PART_NAME] is set to true, skip the part
    if [[ "${!var_name}" == true ]]; then
        echo_progress "Skipping $1"
        return
    fi

    local script_to_execute="$MOD_LOC_CURRENT_SCRIPT_DIR/parts/$MOD_INP_SCRIPT/$1.sh"

    while true; do
        if execute_part_inner "$script_to_execute"; then
            break  # Exit the loop if script executes successfully
        else
            read -r -p "Execution of $1 failed. Do you want to retry? (y/n): " retry_answer
            case $retry_answer in
                [Yy]* ) continue;;  # Continue loop for retry
                * ) exit_script "Aborted. Could not load $script_to_execute";;
            esac
        fi
    done
}

execute_part_inner() {
    local script_to_execute="$1"
    if [ -f "$script_to_execute" ]; then
        # shellcheck disable=SC1090
        . "$script_to_execute"
        return $?  # Return the exit status of the script
    else
        return 1  # Return a non-zero status for failure
    fi
}
