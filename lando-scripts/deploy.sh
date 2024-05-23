#!/bin/bash

# Available MOD_VARs:
# MOD_VAR_PACKAGE_NAME:  Name of the folder and zip file created for the deploy package.
# MOD_VAR_PUBLISH:       Needs to be set for the publish script to run.
# MOD_VAR_RUN_COMPOSER:  If set, composer is run before and after deploy.
#                            If set to "clean", the vendor dir is first removed, and install is run with instead of update.
#
# MOD_VAR_EXTRA_EXCLUDES:   Can be set to a comma-separated string with additional excludes.
#
# MOD_VAR_GIT_TAG_PREFIX:    Prefix for git tags. Added before package version. Defaults to "v", so tag would be "v1.0.0".

if [ -z "$MOD_VAR_PACKAGE_NAME" ]; then
    exit_script "You have to set MOD_VAR_PACKAGE_NAME"
fi

# shellcheck disable=SC2034
MOD_LOC_SKIP_PUBLISH=true # Disables running publish by default, unless MOD_VAR_PUBLISH is set.

if [ -n "$MOD_VAR_PUBLISH" ]; then
    MOD_LOC_SKIP_PUBLISH=false # Enables running publish script.
fi

if [ -n "$MOD_INP_TEST" ]; then
    MOD_LOC_SKIP_GIT_TAG=true # Disables running git tag if this is a test deploy.
fi

echo_progress "Start deploy"

echo_prompt "There are multiple deploy parts available:" true
echo
echo_prompt "p. Package files ready for deploy" true
echo_prompt "u. Publish (upload) package files" true
echo_prompt "g. Create a git tag" true
echo_prompt "a. All of the above" true
echo
read -r -p "Type the letter of the action you want to take: " -n 1
MOD_READ_ACTION=$REPLY


case $MOD_READ_ACTION in

  p)
    echo_progress "You've chosen to package the files."
    ;;

  u)
    echo_progress "You've chosen only to publish."
    MOD_LOC_SKIP_PUBLISH=false
    ;;

  g)
    echo_progress "You've chosen only create a git tag."
    ;;

  a)
    echo_progress "You've opted for the full process. Let's go!"
    ;;

  *)
    exit_script "You have entered an invalid action, please try again."
    ;;
esac

# If $MOD_READ_ACTION is g or a, and MOD_LOC_SKIP_GIT_TAG is not set to true, prompt for the git tag message
if [[ "$MOD_READ_ACTION" =~ [ga] && "$MOD_LOC_SKIP_GIT_TAG" != true ]]; then
    . "$MOD_LOC_CURRENT_SCRIPT_DIR/parts/deploy/git-tag-prep.sh"
fi


# Retrieve the package version using WP-CLI
echo_progress "Getting package version"

MOD_LOC_PACKAGE_VER=$(wp "$MOD_VAR_PACKAGE_TYPE" list --path="$MOD_VAR_WP_PATH" --name="$MOD_VAR_PACKAGE_DEV_NAME" --field=version)
# Check if the version was successfully retrieved
if [ -z "$MOD_LOC_PACKAGE_VER" ]; then
    # Prompt the user for the version number
    echo "Failed to retrieve the version number automatically. Package name: $MOD_VAR_PACKAGE_DEV_NAME, WP Path: $MOD_VAR_WP_PATH."
    read -r -p "Please enter the version number: " user_input
    MOD_LOC_PACKAGE_VER=$user_input
fi

echo_progress "Package version: $MOD_LOC_PACKAGE_VER"


case $MOD_READ_ACTION in

  p)
    execute_part "package"
    ;;

  u)
    execute_part "publish"
    ;;

  g)
    execute_part "git-tag"
    ;;

  a)
    execute_part "package"
    execute_part "publish"
    execute_part "git-tag"
    ;;
esac
