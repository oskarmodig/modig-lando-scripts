#!/bin/bash

MOD_VAR_TAG_PREFIX=${MOD_VAR_TAG_PREFIX:-"v"}

# Using the variables in the git tag command
git tag -a "${MOD_VAR_TAG_PREFIX}${MOD_LOC_PACKAGE_VER}" -m "${MOD_READ_GIT_TAG_MSG}"
git push --follow-tags
