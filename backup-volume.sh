#!/bin/bash

# Define variables
VOLUME_NAME="$1"
BACKUP_PATH="$2"

BACKUP_SUFFIX=$(echo `date +BACKUP%Y%m%d_%H%M%S`)
BKP_VOLUME_NAME="${VOLUME_NAME}_${BACKUP_SUFFIX}"

# Initialize the docker volume that will be filled up with the reference volume's data
docker volume create --name "$BKP_VOLUME_NAME"

# Copy data from the reference volume and into the backup volume
docker container run --rm \
	-v ${VOLUME_NAME}:/from \
	-v ${BKP_VOLUME_NAME}:/to \
	alpine ash -c "cd /from ; cp -av . /to"	

# Zip the volume's data into a *tar.gz file on the specified directory
docker container run --rm \
	-v ${BKP_VOLUME_NAME}:/data \
	-v $(dirname ${BACKUP_PATH}):/backup \
	alpine ash -c "tar -czvf /backup/$(basename ${BACKUP_PATH}) /data" 

# Remove the backup docker volume 
docker volume rm ${BKP_VOLUME_NAME}

