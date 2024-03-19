#!/bin/bash

# Function to install WordPress plugins or themes, with special handling for certain names
# Usage: install_wp_items "plugin or theme" "item1,item2,item3" "declare -A special_items=( [item1]="path/to/script.sh" )"
install_wp_items() {
    local item_type="$1" # 'plugin' or 'theme'
    local items="$2" # Comma-separated string of item names or URLs
    local -n special_items="$3" # Associative array of special items and their scripts

    # Split the items string into an array
    IFS=',' read -r -a item_array <<< "$items"

    # Iterate over the items
    for item in "${item_array[@]}"; do
      # Check if the item is in the special items list
      if [[ -v special_items[$item] ]]; then
        # Execute the special script for this item
        echo "Running special script for $item"
        "${special_items[$item]}"
      else
        # Default wp cli command for item installation
        echo "Installing $item using wp cli"
        call_wp "$item_type" install "$item"
      fi
    done
}
