#!/bin/bash


# Check if the "excludes" section exists
MOD_LOC_EXCLUDES_SECTION_EXISTS=$(grep -c "^excludes:" "$MOD_LOC_LANDO_FILE")

if [ "$MOD_LOC_EXCLUDES_SECTION_EXISTS" -ne 0 ]; then
  echo_progress "Disabling lando excludes"
  # Comment out the excludes section and its contents
  awk '/^excludes:/{flag=1;print "# " $0;next}/^[^ ]/{flag=0}flag{print "# " $0;next}1' "$MOD_LOC_LANDO_FILE" > temp.yml && mv temp.yml "$MOD_LOC_LANDO_FILE"
fi
