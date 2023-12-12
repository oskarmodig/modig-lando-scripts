#!/bin/bash

# Available arguments:
# MOD_VAR_MAIN_WP_NAME:  Name of the folder and zip file created for the main deploy package.
# MOD_VAR_DLF_NAME:      Name of the zip file for DownloadsFlo
# MOD_VAR_JSON:          Name of .json-file to include in downloadsflo-dir. Defaults to info (.json-extension is added automatically)
# MOD_VAR_RUN_COMPOSER:  If set, composer is run before and after deploy.
#                            If set to "clean", the vendor dir is first removed, and install is run with instead of update.
#
# MOD_VAR_EXCLUDE_VENDOR:   If set, the vendor dir is not copied to the package.
#
# MOD_VAR_GIT_TAG_PREFIX:    Prefix for git tags. Added before package version. Defaults to "v", so tag would be "v1.0.0".


# shellcheck disable=SC2034
MOD_LOC_SKIP_PUBLISH=true # Disables running publish by default, unless MOD_VAR_DLF_NAME is set. See parts/deploy/publish.sh

if [ -n "$MOD_INP_TEST" ]; then
    MOD_LOC_SKIP_GIT_TAG=true # Disables running publish by default, unless MOD_VAR_DLF_NAME is set. See parts/deploy/publish.sh
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
    . "$DIR/parts/deploy/git-tag-prep.sh"
fi


# Retrieve the package version using WP-CLI
echo_progress "Getting package version"

MOD_LOC_PACKAGE_VER=$(wp "$MOD_VAR_PACKAGE_TYPE" list --path="$MOD_VAR_WP_PATH" --name="$MOD_VAR_PACKAGE_NAME" --field=version)
check_required_vars "Version for package of typ $MOD_VAR_PACKAGE_TYPE version not found, name: $MOD_VAR_PACKAGE_NAME, WP Path: $MOD_VAR_WP_PATH." MOD_LOC_PACKAGE_VER

echo_progress "Package version: $MOD_LOC_PACKAGE_VER"




execute_part() {
  # Replace dashes with underscores part name, and make it uppercase
  local part_name="$1"
  part_name=${part_name//-/_}
  part_name=${part_name^^}

  local var_name="MOD_LOC_SKIP_$part_name"

  # if variable MOD_LOC_SKIP_[PART_NAME] is set to true, skip the part
  if [[ "${!var_name}" == true ]]; then
    echo_progress "Skipping $1"
    return
  fi

  if [ -f "$DIR/parts/deploy/$1.sh" ]; then
    # shellcheck disable=SC1090
    . "$DIR/parts/deploy/$1.sh"
  fi
}


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
