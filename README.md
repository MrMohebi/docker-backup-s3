istepanov/backup-to-s3
======================

[![Docker Stars](https://img.shields.io/docker/stars/istepanov/backup-to-s3.svg)](https://hub.docker.com/r/istepanov/backup-to-s3/)
[![Docker Pulls](https://img.shields.io/docker/pulls/istepanov/backup-to-s3.svg)](https://hub.docker.com/r/istepanov/backup-to-s3/)
[![Docker Build](https://img.shields.io/docker/automated/istepanov/backup-to-s3.svg)](https://hub.docker.com/r/istepanov/backup-to-s3/)
[![Layers](https://images.microbadger.com/badges/image/istepanov/backup-to-s3.svg)](https://microbadger.com/images/istepanov/backup-to-s3)

Docker container that periodically backups files to Amazon S3 using [s3cmd sync](http://s3tools.org/s3cmd-sync) and cron.

### Usage

    docker run -d [OPTIONS] istepanov/backup-to-s3

### Parameters:

* `-e ACCESS_KEY=<ACCESS_KEY>`: Your access key.
* `-e SECRET_KEY=<SECRET_KEY>`: Your secret secret.
* `-e HOST_BASE=<HOST_BASE>`: S3 endpoint URL.
* `-e S3_PATH=s3://<BUCKET_NAME>/<PATH>/`: S3 Bucket name and path. Should end with trailing slash.
* `-v /path/to/backup:/data:ro`: mount target local folder to container's data folder. Content of this folder will be synced with S3 bucket.

### Optional parameters:

* `-e HOST_BUCKET=<HOST_BUCKET>`: bucket endpoint URL.
* `-e FOLDER_NAME=<NAME>`: base folder name that all DATA_PATH will be copied to. time will be appended (time format:08-09-2022-12:12:38+01:30)
* `-e PARAMS="--dry-run"`: parameters to pass to the sync command ([full list here](http://s3tools.org/usage)).
* `-e DATA_PATH=/data/`: container's data folder. Default is `/data/`. Should end with trailing slash.
* `-e 'CRON_SCHEDULE=0 1 * * *'`: specifies when cron job starts ([details](http://en.wikipedia.org/wiki/Cron)). Default is `0 1 * * *` (runs every day at 1:00 am).
* `no-cron`: run container once and exit (no cron scheduling).

### Examples:

Docker-compose upload multiple files to S3 every 6 hours:

    version: '3.8'
        services:
            php:
                build: .
                container_name: ttt-s3
                restart: always
                volumes:
                    - ./file1.txt:/file1.txt:ro
                    - ./dir1:/dir1:ro
                environment:
                    - ACCESS_KEY=myaccesskey
                    - SECRET_KEY=mysecret
                    - HOST_BASE=https://s3.host.com
                    - S3_PATH=s3://my-bucket/backup/
                    - FOLDER_NAME=custom_prefix_name
                    - DATA_PATH=/file1.txt,/dir1
                    - CRON_SCHEDULE=0 */6 * * *

Run upload to S3 everyday at 12:00pm:

    docker run -d \
        -e ACCESS_KEY=myaccesskey \
        -e SECRET_KEY=mysecret \
        -e HOST_BASE=https://endpoint.com \
        -e S3_PATH=s3://my-bucket/backup/ \
        -e 'CRON_SCHEDULE=0 12 * * *' \
        -v /home/user/data:/data:ro \
        istepanov/backup-to-s3

Run once then delete the container:

    docker run --rm \
        -e ACCESS_KEY=myaccesskey \
        -e SECRET_KEY=mysecret \
        -e HOST_BASE=https://endpoint.com \
        -e S3_PATH=s3://my-bucket/backup/ \
        -v /home/user/data:/data:ro \
        istepanov/backup-to-s3 no-cron

Run once to get from S3 then delete the container:

    docker run --rm \
        -e ACCESS_KEY=myaccesskey \
        -e SECRET_KEY=mysecret \
        -e HOST_BASE=https://endpoint.com \
        -e S3_PATH=s3://my-bucket/backup/ \
        -v /home/user/data:/data:rw \
        istepanov/backup-to-s3 get

Run once to delete from s3 then delete the container:

    docker run --rm \
        -e ACCESS_KEY=myaccesskey \
        -e SECRET_KEY=mysecret \
        -e HOST_BASE=https://endpoint.com \
        -e S3_PATH=s3://my-bucket/backup/ \
        istepanov/backup-to-s3 delete

Security considerations: on restore, this opens up permissions on the restored files widely.
