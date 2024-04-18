!/bin/bash

# Presigned URL
# presigned_url=""
# # Specify the tar file name
# tar_file="vodacom_poc_tables.tar.gz"
# Destination file path
# destination_path=/tmp
import_dir="/var/lib/heavyai/import"

# Database credentials
db_user="admin"
db_pass="HyperInteractive"
db_name="replica"

# # Download the file using curl
# curl -o "$destination_path/$tar_file" "$presigned_url"

# Check if download was successful
# if [ $? -eq 0 ]; then
#     echo "File downloaded successfully to $destination_path"
# else
#     echo "Failed to download file from $presigned_url"
#     exit 1
# fi

# Change to the directory where the tar file is located
# cd "$destination_path" || { echo "Directory not found"; exit 1; }

# Check if the tar file exists
# if [ -f "$tar_file" ]; then
#     # Extract the tar file
#     tar -xzf "$tar_file" -C "$import_dir"
#     echo "File $tar_file extracted successfully to $import_dir"
# else
#     echo "Tar file $tar_file not found in $destination_path"
#     exit 1
# fi

# Loop through each file in the directory
for file in "$import_dir"/*.lz4; do
    if [ -f "$file" ]; then
        table_name=$(echo "$file" | sed 's/\.lz4$//' | sed 's/.*\///')
    SQL="
        RESTORE TABLE $table_name
        FROM '$file'
        WITH (COMPRESSION='lz4');"

        echo "Restoring $file ..."
    HEAVY_SQL_COMMAND="/opt/heavyai/bin/heavysql --db $db_name -u $db_user -p $db_pass"
        echo $SQL | docker-compose exec -T heavyaiserver $HEAVY_SQL_COMMAND
        echo "Restore complete for $file"
    else
        echo "No Heavy dump files found in $import_dir"
        exit 1
    fi


echo "All Heavy dump files restored successfully"
done
