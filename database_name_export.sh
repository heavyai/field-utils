#!/usr/bin/env bash

# Steps
# 1 - Define a place to export everything
# 2 - Identify dashboards and tables
# 3 - Export to folder

# Must be run within docker container
# Execute script with the following command
# docker exec -it <container_name> /path/to/script/database_name_export.sh

# Set credentials, ask as input? todo
USER="admin"
PW="HyperInteractive"
output_file="/var/lib/heavyai/export/database_list.txt"



# Get count of databases, accounting for 3 extra lines of heavysql output
count=$(echo "\l" | bin/heavysql -u admin -p HyperInteractive | wc -l)
count=$(("$count" - 3))

echo "Exporting list of $count databases"

databases=$(echo "\l" | bin/heavysql -u $USER -p $PW)

# Read input into an array
readarray -t lines <<< "$databases"

# Initialize an empty array to hold the extracted values
# declare -a database_names

# Loop through the lines, skipping the header
for ((i=1; i<${#lines[@]}; i++)); do
  # Extract the first pipe-separated value using awk
  name=$(echo "${lines[$i]}" | awk -F'|' '{print $1}' | xargs)

  if [ "$name" = "Database" ] || [ "$name" = "User admin disconnected from database heavyai" ] || [ "$name" = "ookla" ]; then
      echo "Skipping \"$name\""
  else
    #   database_names+=("$name")
      echo "Found database \"$name\""
      echo "$name" >> "$output_file"

  fi
  
done



# Print the array elements to verify
# echo "Extracted Database Names:"
# for name in "${database_names[@]}"; do
#   echo "Found database \"$name\""
# #   echo "\export_dashboard \"$name\" \"$FILEPATH/dashboards/$name.json\"" | bin/heavysql -u $USER -p $PW --db $DB
# done

# write to file todo