# Example usage:
# load_env_file "/path/to/.env"
# This will load the .env file and set the variables in the current shell.
# It will also exit the script with a warning if the file is not found.
# This function can be used to load .env files in a script, and make the variables available to the rest of the script.
load_env_file() {
  local env_file="$1"
  if [ -f "$env_file" ]; then
    set -a  # Automatically export all variables
    # shellcheck disable=SC1090
    source "$env_file"
    set +a  # Disable auto-export
  else
    echo_error "Warning: .env file '$env_file' not found."
  fi
}
