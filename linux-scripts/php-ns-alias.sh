#!/bin/bash

if [ -z "$MODIG_NAMESPACE_ALIAS_DIRECTORY" ]; then
    exit_script "Variable MODIG_NAMESPACE_ALIAS_DIRECTORY is required"
fi

if [ -z "$MODIG_NAMESPACE_ALIAS_ORIGINAL_NAMESPACE" ]; then
    exit_script "Variable $MODIG_NAMESPACE_ALIAS_ORIGINAL_NAMESPACE is required"
fi

if [ -z "$MODIG_NAMESPACE_ALIAS_PACKAGE_NAMESPACE" ]; then
    exit_script "Variable $MODIG_NAMESPACE_ALIAS_PACKAGE_NAMESPACE is required"
fi

# Run php file
PHP_SCRIPT_PATH=$MOD_LOC_CURRENT_SCRIPT_DIR/parts/php-class-alias/generate-aliases.php
php "$PHP_SCRIPT_PATH" "$MODIG_NAMESPACE_ALIAS_DIRECTORY" "$MODIG_NAMESPACE_ALIAS_ORIGINAL_NAMESPACE" "$MODIG_NAMESPACE_ALIAS_PACKAGE_NAMESPACE"
