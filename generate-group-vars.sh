#!/bin/bash
#
# Copyright 2024 Roberto Leinardi.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Define the output file
output_file="inventory/group_vars/all.yaml"

# Create or empty the output file and add the initial YAML document separator
{
  echo "# Automatically generated from roles' defaults"
  echo "---"
} > "$output_file"

# Loop through each role's defaults/main.yaml file
for role in $(find roles -mindepth 1 -maxdepth 1 -type d | sort); do
  defaults_file="$role/defaults/main.yaml"

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

echo "inventory/group_vars/all.yaml has been generated."
