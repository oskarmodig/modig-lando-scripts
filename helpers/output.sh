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

exit_script() {
  echo
  echo -e "${RED}ERROR:${NC} $1"
  echo
  exit 1;
}
