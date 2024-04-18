#!/bin/bash
source ./config.sh

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "AWS Credentials are not set in the config.sh file.  Please update these to enable connection to AWS based assets"
    exit

fi

if [ $# -eq 0 ]; then
    echo "Usage:  loadDataPackage <packageFile.json> <dbname>"
    exit
else
    PACKAGE_NAME=$1
    if [ -z $2 ]; then
        DB_NAME="heavyai"
    else
        DB_NAME=$2
    fi
fi

#build database
SQL="CREATE DATABASE IF NOT EXISTS $DB_NAME ;"
HEAVY_SQL_COMMAND="/opt/heavyai/bin/heavysql -u admin -p HyperInteractive"
echo $SQL | docker-compose exec -T heavyaiserver $HEAVY_SQL_COMMAND

# Load Data Dump Files
while read TABLE_NAME && read filetype && read FILEPATH; do

    SQL="
        RESTORE TABLE ${TABLE_NAME} 
        FROM '$FILEPATH'
        WITH (COMPRESSION='${filetype}', 
        S3_REGION='$AWS_REGION', 
        S3_ACCESS_KEY='$AWS_ACCESS_KEY_ID', 
        S3_SECRET_KEY='$AWS_SECRET_ACCESS_KEY');"

    echo "statement" $SQL
    HEAVY_SQL_COMMAND="/opt/heavyai/bin/heavysql -u admin -p HyperInteractive -db $DB_NAME"
    echo $SQL | docker-compose exec -T heavyaiserver $HEAVY_SQL_COMMAND
done < <(jq -r '.dataFiles[] | .tablename, .filetype, .filepath' ./$PACKAGE_NAME)

