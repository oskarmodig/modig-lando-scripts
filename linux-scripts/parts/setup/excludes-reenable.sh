#!/bin/bash
# Uncomment the "excludes" section and its contents
if [ "$MOD_LOC_EXCLUDES_SECTION_EXISTS" -ne 0 ]; then
  echo_progress "Re enabling lando excludes"
  sed -i '/^# excludes:/,/^# [^ ]/ s/^# //' "$MOD_LOC_LANDO_FILE"
fi