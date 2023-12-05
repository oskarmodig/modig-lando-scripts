#!/bin/bash

# Get input arguments
for ARGUMENT in "$@"
do
   KEY=$(echo "$ARGUMENT" | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

# Check if MOD_INP_TEST is set
if [[ -n $MOD_INP_TEST ]]; then
    # Use the pattern with TEST
    PATTERN="MOD_VAR__${MOD_INP_ENV}__TEST__*"
else
    # Use the pattern without TEST
    PATTERN="MOD_VAR__${MOD_INP_ENV}__*"
fi

# Loop through all environment variables and remove the environment prefix
for var in $(compgen -v); do
    # Check if the variable starts with the desired pattern
    if [[ $var == "$PATTERN" ]]; then
        # Construct the new variable name
        if [[ -n $MOD_INP_TEST ]]; then
            # Remove both dynamic part and TEST
            new_var_name="MOD_VAR_${var#MOD_VAR__${MOD_INP_ENV}__TEST__}"
        else
            # Remove only dynamic part
            new_var_name="MOD_VAR_${var#MOD_VAR__${MOD_INP_ENV}__}"
        fi

        # Assign the value of the old variable to the new one
        eval "$new_var_name='${!var}'"

        # Unset the old variable
        unset "$var"
    fi
done
