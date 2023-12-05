#!/bin/bash

# Available arguments:
#
# MOD_VAR_DLF: Name of the zip file for DownloadsFlo


# shellcheck disable=SC2034
MOD_VAR_SKIP_PUBLISH=true # Disables running publish by default, unless MOD_VAR_DLF is set. See parts/deploy/publish.sh

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
    echo_progress "You've chosen only to publish."
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


# Retrieve the package version using WP-CLI
echo_progress "Getting package version"
MOD_VAR_VER=$(wp "$MOD_VAR_PACKAGE_TYPE" list --path="$MOD_VAR_WP_PATH" --name="$MOD_VAR_PACKAGE" --field=version)
if [ -z "$MOD_VAR_VER" ]; then
    exit_script "Plugin/Theme version not found."
fi
echo_progress "Package version: $MOD_VAR_VER"

# If $ACTION is g or a, prompt for the git tag message
if [[ "$ACTION" =~ [ga] ]]; then
    echo_prompt "Enter a git tag message:" true
    read -r MOD_VAR_GIT_TAG_MSG
fi


execute_part() {
  # if variable MOD_VAR_SKIP_$1 is set to true, skip the part
  if [[ "${!MOD_VAR_SKIP_$1}" == true ]]; then
    echo_progress "Skipping $1"
    return
  fi

  if [ -f "$DIR/parts/deploy/$1.sh" ]; then
    # shellcheck disable=SC1090
    . "$DIR/parts/deploy/$1.sh"
  fi
}


case $ACTION in

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
