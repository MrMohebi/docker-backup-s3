#!/bin/bash

set -e

echo "Job started: $(date)"

NOW=$(date +"%d-%m-%Y-%T%:z")
BACKUP_FOLDER = "$FOLDER_NAME-$NOW"
mkdir "$BACKUP_FOLDER"

readarray -td, DATA_PATH_ARR <<<"$DATA_PATH"; declare -p DATA_PATH_ARR;

for i in ${DATA_PATH_ARR[@]}; do
  cp -r "$i" "$BACKUP_FOLDER"
done


/usr/local/bin/s3cmd put $PARAMS "$BACKUP_FOLDER" "$S3_PATH"

echo "Job finished: $(date)"
