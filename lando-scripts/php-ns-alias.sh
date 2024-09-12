#!/bin/bash

if [ -z "$MOD_VAR_NAMESPACE_ALIAS_DIRECTORY" ]; then
    exit_script "Variable MOD_VAR_NAMESPACE_ALIAS_DIRECTORY is required"
fi

if [ -z "$MOD_VAR_NAMESPACE_ALIAS_ORIGINAL_NAMESPACE" ]; then
    exit_script "Variable $MOD_VAR_NAMESPACE_ALIAS_ORIGINAL_NAMESPACE is required"
fi

if [ -z "$MOD_VAR_NAMESPACE_ALIAS_PACKAGE_NAMESPACE" ]; then
    exit_script "Variable $MOD_VAR_NAMESPACE_ALIAS_PACKAGE_NAMESPACE is required"
fi

MOD_VAR_NAMESPACE_ALIAS_PACKAGE_NAMESPACE="$MOD_VAR_NAMESPACE_ALIAS_PACKAGE_NAMESPACE\\\\$MOD_VAR_NAMESPACE_ALIAS_ORIGINAL_NAMESPACE"

# Run php file
PHP_SCRIPT_PATH=$MOD_LOC_CURRENT_SCRIPT_DIR/parts/php-ns-alias/generate-aliases.php
php "$MOD_VAR_PACKAGE_PATH" "$PHP_SCRIPT_PATH" "$MOD_VAR_NAMESPACE_ALIAS_DIRECTORY" "$MOD_VAR_NAMESPACE_ALIAS_ORIGINAL_NAMESPACE" "$MOD_VAR_NAMESPACE_ALIAS_PACKAGE_NAMESPACE"
