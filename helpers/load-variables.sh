#!/bin/bash

# Get input arguments
for ARGUMENT in "$@"
do
   KEY=$(echo "$ARGUMENT" | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

# Change value of $MOD_INP_ENV to uppercase
MOD_INP_ENV=${MOD_INP_ENV^^}

# Define the function with a parameter to determine the pattern
process_variables() {
    local include_test=$1  # This parameter determines if TEST__ should be included in the pattern

    # Determine the pattern based on the include_test parameter
    if [[ $include_test == "yes" ]]; then
        PATTERN="MOD_VAR__${MOD_INP_ENV}_TEST__*"
    else
        PATTERN="MOD_VAR__${MOD_INP_ENV}__*"
    fi

    # Loop through all environment variables
    for var in $(compgen -v); do
        if [[ $var == $PATTERN ]]; then
            # Construct the new variable name
            if [[ $include_test == "yes" ]]; then
                new_var_name="MOD_VAR_${var#MOD_VAR__${MOD_INP_ENV}_TEST__}"
            else
                new_var_name="MOD_VAR_${var#MOD_VAR__${MOD_INP_ENV}__}"
            fi

            # Assign the value of the old variable to the new one
            eval "$new_var_name='${!var}'"

            # Unset the old variable
            unset "$var"
        fi
    done
}

# Call the function for the pattern without TEST__
process_variables "no"

# If MOD_INP_TEST is set, call the function for the pattern with TEST__
if [[ -n $MOD_INP_TEST ]]; then
    process_variables "yes"
fi
