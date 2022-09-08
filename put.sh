#!/bin/bash

set -e

echo "Job started: $(date)"

NOW=$(date +"%d-%m-%Y-%T%:z")
BACKUP_FOLDER="$FOLDER_NAME-$NOW"
mkdir "$BACKUP_FOLDER"


IFS=',' read -r -a DATA_PATH_ARR <<< "$DATA_PATH"

for i in ${DATA_PATH_ARR[@]}; do
  cp -r "$i" "$BACKUP_FOLDER"
done

ls -la $BACKUP_FOLDER

/usr/local/bin/s3cmd put --recursive $PARAMS $BACKUP_FOLDER $S3_PATH

echo "Job finished: $(date)"
