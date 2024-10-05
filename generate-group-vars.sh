#!/bin/bash

# Define the output file
output_file="group_vars/all.yml"

# Create or empty the output file and add the initial YAML document separator
{
  echo "# Automatically generated from roles' defaults"
  echo "---"
} > "$output_file"

# Loop through each role's defaults/main.yml file
for role in roles/*; do
  defaults_file="$role/defaults/main.yml"

  if [ -f "$defaults_file" ]; then
    {
      echo "# Variables from $role"
      # Remove any document separators ('---') from the defaults file before appending
      sed '/^---/d' "$defaults_file"
      echo ""  # Add an extra newline for separation
    } >> "$output_file"
  fi
done

# Remove the last newline to avoid two trailing newlines
truncate -s -1 "$output_file"

echo "group_vars/all.yml has been generated."
