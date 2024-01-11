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

  MESSAGE=${2:-"Could not change directory."}
  cd "$CD_PATH" || exit_script "$MESSAGE Path: $CD_PATH"
  echo_progress "Changed directory to $CD_PATH"
}

# Function to handle composer operations
handle_composer() {
  local composer_params="--no-dev --optimize-autoloader"

  local original_dir
  original_dir=$(pwd)

  change_dir "$MOD_VAR_PACKAGE_PATH" "Could not change dir for composer"

  # If the first parameter is true, clear the additional parameters to reset composer for development
  if [ "$1" = "true" ]; then
    composer_params=""
  fi

  # Execute the composer commands
  if [ "$MOD_VAR_RUN_COMPOSER" = "clean" ]; then
    remove_dir vendor/
    # Remove composer.lock to avoid conflicts
    rm -f composer.lock
    # shellcheck disable=SC2086
    composer install $composer_params
  else
    # shellcheck disable=SC2086
    composer update $composer_params
  fi

  change_dir "$original_dir" "Original dir not found."
}

url_encode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote_plus('$1'))"
}
