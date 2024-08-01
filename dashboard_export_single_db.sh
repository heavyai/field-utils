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
DB="heavyai"
FILEPATH="/var/lib/heavyai/export/backup/$DB"

# change sql query to get all tables, this gets all tables that are used in dashboards
# table_query="SELECT UNNEST(data_sources) AS c FROM information_schema.dashboards where database_name = '$DB' group by c;"
table_query="SELECT table_name FROM information_schema.tables where database_name = '$DB';"


# Get count of dashboards, accounting for 3 extra lines of heavysql output
count=$(echo "\dash" | bin/heavysql -u admin -p HyperInteractive --db heavyai | wc -l)
count=$(("$count" - 3))

echo "Exporting $count dashboards to $FILEPATH/dashboards"

dashboards=$(echo "\dash" | bin/heavysql -u $USER -p $PW --db $DB)

# Read input into an array
readarray -t lines <<< "$dashboards"

# Initialize an empty array to hold the extracted values
declare -a dashboard_names

# Loop through the lines, skipping the header
for ((i=1; i<${#lines[@]}; i++)); do
  # Extract the second pipe-separated value using awk
  name=$(echo "${lines[$i]}" | awk -F'|' '{print $2}' | xargs)
  dashboard_names+=("$name")
done

# Print the array elements to verify
echo "Extracted Dashboard Names:"
for name in "${dashboard_names[@]}"; do
  echo "Exporting dashboard \"$name\" to $FILEPATH/dashboards/"
  echo "\export_dashboard \"$name\" \"$FILEPATH/dashboards/$name.json\"" | bin/heavysql -u $USER -p $PW --db $DB
done



# Export tables

# Get table count
table_count=$(echo "$table_query" | bin/heavysql -u admin -p HyperInteractive --db heavyai | wc -l)
table_count=$(("$table_count" - 3))

echo "Exporting $table_count tables to $FILEPATH/tables"


tables=$(echo "$table_query" | bin/heavysql -u $USER -p $PW --db $DB)

readarray -t lines <<< "$tables"


# Print the array elements to verify
echo "Extracted Table Names:"
for name in "${lines[@]}"; do
  echo "Exporting table \"$name\" to $FILEPATH/tables/"
  echo "dump table $name to '$FILEPATH/tables/$name.dump.gz' with (COMPRESSION = 'gzip');" | bin/heavysql -u $USER -p $PW --db $DB
done