#!/bin/bash

set -e

echo "Job started: $(date)"

cd /root

NOW=$(date +"%d-%m-%Y-%H%M%S%z")
BACKUP_FOLDER="$FOLDER_NAME-$NOW"
mkdir "$BACKUP_FOLDER"

cp -a "$DATA_PATH". "$BACKUP_FOLDER"

TAR_FILE="${BACKUP_FOLDER}.tar.gz"
tar -czvf "$TAR_FILE" "$BACKUP_FOLDER"

/usr/local/bin/s3cmd put --recursive "$PARAMS" "$TAR_FILE" "$S3_PATH"


if [ -n "$MAX_AGE" ] ; then
/usr/local/bin/s3cmd ls "$S3_PATH" | grep " DIR " -v | while read -r line;
                       do
                         strArr=($line)
                         createDate="${strArr[0]} ${strArr[1]}"
                         createDate=$(date -d "$createDate" "+%s")
                         olderThan=$(date -d "$MAX_AGE ago" "+%s")
                         if [[ $createDate -le $olderThan ]]; then
                             fileName=`echo $line|awk {'print $4'}`
                             if [ "$fileName" != "" ]; then
                                 printf 'Deleting "%s"\n' "$fileName"
                                 /usr/local/bin/s3cmd del "$fileName"
                             fi
                         fi
                       done;
fi

echo "current directory: $(pwd)"

ls -la

echo "removing backup folder in: $BACKUP_FOLDER"
rm -rf "$BACKUP_FOLDER"

echo "removing backup TAR file in: $TAR_FILE"
rm -rf "$TAR_FILE"

echo "Job finished: $(date)"
