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
    local include_test=$1
    local pattern_prefix="MOD_VAR__${MOD_INP_ENV}"
    [ "$include_test" == "yes" ] && pattern_prefix="${pattern_prefix}_TEST"

    for var in $(compgen -v); do
        if [[ $var == ${pattern_prefix}* ]]; then
            # Remove the pattern prefix and the following underscore
            new_var_suffix="${var#${pattern_prefix}_}"
            new_var_name="MOD_VAR$new_var_suffix"
            eval "$new_var_name='${!var}'"
        fi
    done
}

# Call the function for the pattern without TEST__
process_variables "no"

# If MOD_INP_TEST is set, call the function for the pattern with TEST__
if [[ -n $MOD_INP_TEST ]]; then
    process_variables "yes"
fi
