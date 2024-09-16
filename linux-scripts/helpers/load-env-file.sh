# Example usage:
# load_env_file "/path/to/.env"
# This will load the .env file and set the variables in the current shell.
# It will also exit the script with a warning if the file is not found.
# This function can be used to load .env files in a script, and make the variables available to the rest of the script.
load_env_file() {
  local env_file="$1"
  local tmp_file="/tmp/env_tmp"

  if [ -f "$env_file" ]; then
    set -a  # Automatically export all variables
    # Remove carriage returns and save to a tmp file
    tr -d '\r' < "$env_file" > "$tmp_file"
    # source the tmp file
    # shellcheck disable=SC1090
    source "$tmp_file"
    set +a  # Disable auto-export
    # remove the tmp file
    rm "$tmp_file"
  else
    echo_notice ".env file '$env_file' not found."
  fi
}
