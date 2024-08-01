#!/bin/bash

# File containing the list of names
file="database_list.txt"

# Print the current directory
# echo "Current directory: $(pwd)"

# Check if the file exists
if [[ ! -f "$file" ]]; then
  echo "File $file not found!"
  exit 1
fi

# Read the file into an array
mapfile -t names < "$file"

# Create 'backup' directory
backup_dir="backup"
mkdir -p "$backup_dir"

# Loop through the list of names and create the directory structure
for name in "${names[@]}"; do
  # Create the main directory for each name
  name_dir="$backup_dir/$name"
  mkdir -p "$name_dir"

  # Create 'dashboards' and 'tables' subdirectories
  mkdir -p "$name_dir/dashboards"
  mkdir -p "$name_dir/tables"
done

echo "Directory structure created successfully."
