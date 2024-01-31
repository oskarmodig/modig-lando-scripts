#!/bin/bash

# Set value for MOD_VAR_PACKAGE_TYPE if not provided
MOD_VAR_PACKAGE_TYPE=${MOD_VAR_PACKAGE_TYPE:-"plugin"}

# Determine the package name, either from the provided variable or from the LANDO_APP_NAME
if [ -z "$MOD_VAR_PACKAGE_DEV_NAME" ]; then
  check_required_vars "You have to supply a plugin/theme name in MOD_VAR_PACKAGE_DEV_NAME, not found from LANDO_APP_NAME." LANDO_APP_NAME
  MOD_VAR_PACKAGE_DEV_NAME=$LANDO_APP_NAME
fi
