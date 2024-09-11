#!/bin/bash

# Fetch the last commit message
last_commit_message=$(git log -1 --pretty=%B)

if [[ $last_commit_message != "ups ver to "* ]]; then
  read -p "The last commit does not start with 'ups ver to '. Continue? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit_script "Aborted."
  fi
fi


echo_prompt "Enter a git tag message:" true
read -r MOD_READ_GIT_TAG_MSG

echo_prompt "Enter your git password:" true
read -r -s MOD_READ_GIT_PASSWORD
