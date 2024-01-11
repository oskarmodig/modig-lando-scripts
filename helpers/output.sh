#!/bin/bash

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'

echo_progress() {
  if [[ -z "$2" ]]; then echo; fi
  echo -e "${GREEN}STATUS:${NC} $1"
  if [[ -z "$2" ]]; then echo; fi
}

echo_notice() {
  if [[ -z "$2" ]]; then echo; fi
  echo -e "${YELLOW}NOTICE:${NC} $1"
  if [[ -z "$2" ]]; then echo; fi
}

echo_prompt() {
  if [[ -z "$2" ]]; then echo; fi
  echo -e "${PURPLE}PROMPT:${NC} $1"
  if [[ -z "$2" ]]; then echo; fi
}

echo_error() {
  if [[ -z "$2" ]]; then echo; fi
  echo -e "${RED}ERROR:${NC} $1"
  if [[ -z "$2" ]]; then echo; fi
}

exit_script() {
  echo_error "$1" "$2"
  exit 1;
}

# Function to check required variables
check_required_vars() {
    local error_message=$1
    shift  # Shift arguments so we can iterate over the rest of them

    for var in "$@"; do
        if [ -z "${!var}" ]; then
            exit_script "$error_message"
        fi
    done
}
