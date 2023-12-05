## GENERAL HELPERS

# Function to create a directory
create_dir() {
  mkdir -p "$1"
}

# Function to remove a directory
remove_dir() {
  rm -rf "$1"
}

change_dir() {
  if [ "$3" = true ]; then
      CD_PATH="$MOD_VAR_PACKAGE_PATH/$1"
  else
      CD_PATH="$1"
  fi

  MESSAGE=${$2:-"Could not change directory."}
  cd "$CD_PATH" || exit_script "$MESSAGE Path: $CD_PATH"
  echo_progress "Changed directory to $CD_PATH"
}

# Function to handle composer operations
handle_composer() {
  local composer_params="--no-dev --optimize-autoloader"

  # If the first parameter is true, clear the additional parameters to reset composer for development
  if [ "$1" = "true" ]; then
    composer_params=""
  fi

  # Execute the composer commands
  if [ "$MOD_VAR_RUN_COMPOSER" = "clean" ]; then
    remove_dir vendor/
    # shellcheck disable=SC2086
    composer install $composer_params
  else
    # shellcheck disable=SC2086
    composer update $composer_params
  fi
}
