#!/bin/bash

if [ "$(id -u)" -eq 0 ]; then
    echo "This script should not be run as root. Please run as a non-root user."
    exit 1
fi


# Check if 'lando' is not available
if ! command -v lando >/dev/null 2>&1; then
    echo_error "Lando is not installed. Please install it to continue."
    echo "It has to be installed specifically for Linux"
    echo "https://docs.lando.dev/getting-started/installation.html#linux"
    echo
    echo "Read the caveat about docker-ce"
    echo "Running Windows and WSL? If you're on Windows with WSL, Docker Desktop installed with lando on Windows should be enough, just make sure to activate the WSL integration in Settings > Resources, and restart your computer."

    exit 1
fi
