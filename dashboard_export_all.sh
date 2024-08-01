#!/usr/bin/env bash

# Steps
# 1 - Define a place to export everything
# 2 - Identify dashboards and tables
# 3 - Export to folder

# Must be run within docker container
# Execute script with the following command
# docker exec -it <container_name> /path/to/script/dashboard_export_all.sh

# Set credentials, ask as input? todo
USER="admin"
PW="HyperInteractive"
FILEPATH="/var/lib/heavyai/export/data_backup"

# File containing the list of databases
file="$FILEPATH/database_list.txt"


# Check if the file exists
if [[ ! -f "$file" ]]; then
  echo "File $file not found!"
  exit 1
fi

# Read the file into an array
mapfile -t databases < "$file"

# Loop through the list of names and create the directory structure
for db in "${databases[@]}"; do
  # Perform backup for each database
  echo "Exporting dashboards and tables from $db"
  
  # Get count of dashboards, accounting for 3 extra lines of heavysql output
  count=$(echo "\dash" | bin/heavysql -u admin -p HyperInteractive --db heavyai | wc -l)
  count=$(("$count" - 3))

  echo "Exporting $count dashboards to $FILEPATH/backup/$db/dashboards"

  dashboards=$(echo "\dash" | bin/heavysql -u $USER -p $PW --db $db)

  # Read input into an array
  readarray -t lines <<< "$dashboards"

  # Loop through the lines, skipping the header
  for ((i=1; i<${#lines[@]}; i++)); do
    # Extract the second pipe-separated value using awk
    name=$(echo "${lines[$i]}" | awk -F'|' '{print $2}' | xargs)

    if [ "$name" = "Dashboard Name" ] || [ "$name" = "" ]; then
      echo "Skipping \"$name\""
    else
      echo "Exporting dashboard \"$name\" to $FILEPATH/backup/$db/dashboards/"
      echo "\export_dashboard \"$name\" \"$FILEPATH/backup/$db/dashboards/$name.json\"" | bin/heavysql -u $USER -p $PW --db $db
    fi
  done



  # Export tables

  # Get table count
  # change sql query to get all tables, this gets all tables that are used in dashboards
  # table_query="SELECT UNNEST(data_sources) AS c FROM information_schema.dashboards where database_name = '$db' group by c;"
  table_query="SELECT table_name FROM information_schema.tables where database_name = '$db';"

  table_count=$(echo "$table_query" | bin/heavysql -u admin -p HyperInteractive --db heavyai | wc -l)
  table_count=$(("$table_count" - 3))

  echo "Exporting $table_count tables to $FILEPATH/backup/$db/tables"


  tables=$(echo "$table_query" | bin/heavysql -u $USER -p $PW --db $db)

  readarray -t lines <<< "$tables"


  # Loop over tables and extract
  for name in "${lines[@]}"; do
    if [ "$name" = "User admin connected to database $db" ] || [ "$name" = "table_name" ] || [ "$name" = "User admin disconnected from database $db" ] || [ "$name" = "" ]; then
      echo "Skipping \"$name\""
    else
      echo "Exporting table \"$name\" to $FILEPATH/backup/$db/tables/"
      echo "dump table $name to '$FILEPATH/backup/$db/tables/$name.dump.gz' with (COMPRESSION = 'gzip');" | bin/heavysql -u $USER -p $PW --db $db
    fi
  done

done




