#!/bin/bash

# Available arguments:
#
# MOD_VAR_DLF: Name of the zip file for DownloadsFlo

echo_progress "Start deploy"

echo_prompt "What do you want to do? Type the letter of the action you want to take:" true
echo
echo_prompt "p. Package files ready for deploy" true
echo_prompt "u. Publish (upload) package files" true
echo_prompt "a. All of the above" true
echo
read -r ACTION


case $ACTION in

  p)
    echo_progress "You've chosen to package the files."
    ;;

  u)
    echo_progress "You've chosen to only publish."
    ;;

  a)
    echo_progress "You've opted for the full process. Let's go!"
    ;;

  *)
    exit_script "You have entered an invalid action, please try again."
    ;;
esac


# Retrieve the package version using WP-CLI
echo_progress "Getting package version"
MOD_VAR_VER=$(wp "$MOD_VAR_PACKAGE_TYPE" list --path="$MOD_VAR_WP_PATH" --name="$MOD_VAR_PACKAGE" --field=version)
if [ -z "$MOD_VAR_VER" ]; then
    exit_script "Plugin/Theme version not found."
fi
echo_progress "Package version: $MOD_VAR_VER"


case $ACTION in

  p)
    . "$DIR/parts/package.sh"
    ;;

  u)
    . "$DIR/parts/publish.sh"
    ;;

  a)
    . "$DIR/parts/package.sh"
    . "$DIR/parts/publish.sh"
    ;;
esac
