#!/bin/bash

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

  if [ -f "$MOD_LOC_CURRENT_SCRIPT_DIR/parts/$MOD_INP_SCRIPT/$1.sh" ]; then
    # shellcheck disable=SC1090
    . "$MOD_LOC_CURRENT_SCRIPT_DIR/parts/$MOD_INP_SCRIPT/$1.sh"
  else
    exit_script "Could not load $MOD_LOC_CURRENT_SCRIPT_DIR/parts/$MOD_INP_SCRIPT/$1.sh"
  fi
}
