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

url_encode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote_plus('$1'))"
}

# Function to find the main plugin file
# Takes one argument: the directory to search in
find_main_plugin_file() {
    local plugin_dir=$1
    for file in "$plugin_dir"/*.php; do
        # Check if the file contains a Plugin Name declaration
        if grep -q "Plugin Name:" "$file"; then
            echo "$file"
            return
        fi
    done
}


command_exists() {
    command -v "$1" >/dev/null 2>&1
}
