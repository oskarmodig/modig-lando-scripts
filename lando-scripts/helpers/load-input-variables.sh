#!/bin/bash

# Get script input arguments
for ARGUMENT in "$@"
do
   KEY=$(echo "$ARGUMENT" | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

# Change value of $MOD_INP_ENV to uppercase
MOD_INP_ENV=${MOD_INP_ENV^^}
