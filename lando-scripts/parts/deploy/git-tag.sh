#!/bin/bash

change_dir "$MOD_VAR_PACKAGE_PATH" "Package path not found."

MOD_VAR_GIT_TAG_PREFIX=${MOD_VAR_GIT_TAG_PREFIX:-"v"}

# URL encode the password
MOD_READ_GIT_PASSWORD=$(url_encode "${MOD_READ_GIT_PASSWORD}")

# Create the tag
tag="${MOD_VAR_GIT_TAG_PREFIX}${MOD_LOC_PACKAGE_VER}"
if ! git tag -a "$tag" -m "${MOD_READ_GIT_TAG_MSG}"; then
  exit_script "Failed to create git tag"
fi

# Push the tag to the remote repository
repo_url="https://${MOD_VAR_GIT_USERNAME}:${MOD_READ_GIT_PASSWORD}@gitlab.com/${MOD_VAR_GIT_REPO}"

if ! git push "$repo_url"; then
  exit_script "Failed to push the git repo"
fi
if ! git push "$repo_url" --tags; then
  exit_script "Failed to push the git tag"
fi
echo_progress "Git tag created and pushed to remote repository"
