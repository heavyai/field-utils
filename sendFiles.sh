#!/bin/bash

# Assign the first argument as the SOURCE
SOURCE="$1"
SUB_DIR="landcover/"

# Default URL to which files will be uploaded
UPLOAD_URL="https://objectstorage.ca-montreal-1.oraclecloud.com/p/WsN-Z2f7T1JdF5EfuUMCUJEH_uedOr1pGoAoKDG0zN7AaEg2rX-qB3_sZM0bs7Ub/n/axckvl28kcnu/b/bchydro-bucket/o/"

# Notify the user of the current UPLOAD_URL and offer a chance to modify it
echo "Current upload URL is: $UPLOAD_URL"
read -p "Press enter to accept the default or enter a new URL: " input_url

# If the user enters a new URL, update UPLOAD_URL
if [ ! -z "$input_url" ]; then
    UPLOAD_URL="$input_url"
fi

# Function to upload a file
upload_file() {
    local file=$1
    FULL_PATH="$UPLOAD_URL$SUB_DIR$(basename "$file")"
    echo "Uploading ${file} to $FULL_PATH"
    response=$(curl --progress-bar --request PUT --upload-file "$file" "$FULL_PATH")
    echo "Response: $response"
}

# Function to upload files from a list in a text file
upload_files_from_list() {
    local list_file=$1
    while IFS= read -r file_path; do
        if [[ -f "$file_path" ]]; then
            upload_file "$file_path"
        else
            echo "Warning: $file_path listed in $list_file does not exist or is not a file."
        fi
    done < "$list_file"
}

# Determine action based on the type of SOURCE
if [ -d "$SOURCE" ]; then
    # SOURCE is a directory; upload each file in the directory
    for file in "$SOURCE"/*; do
        if [[ -f "$file" ]]; then
            upload_file "$file"
        fi
    done
elif [ -f "$SOURCE" ]; then
    # SOURCE is a file; check if it's a text file with a list of files or a single file to upload
    if [[ $SOURCE == *.txt ]]; then
        # SOURCE is a text file; read and upload files listed in it
        upload_files_from_list "$SOURCE"
    else
        # SOURCE is a single file to upload
        upload_file "$SOURCE"
    fi
else
    echo "Error: $SOURCE does not exist or is not a valid file/directory."
    exit 1
fi

