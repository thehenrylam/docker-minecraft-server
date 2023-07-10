#!/bin/bash

# Define variables
VOLUME_NAME="$1" # The name of the volume that the bkp-object will fill the data to
BKP_OBJECT_PATH="$2" # The name of the bkp-object (Assumed to be a *tar.gz file)

# Create a temporary container to restore the volume
# docker container create -v ${VOLUME_NAME}:/data --name restore_container alpine:latest 

if docker volume inspect $VOLUME_NAME >/dev/null 2>&1; then
	echo "Volume $VOLUME_NAME already exists, renaming it to a different volume name."
	./rename-volume.sh "${VOLUME_NAME}" "${VOLUME_NAME}_bkp$(date +%Y%m%d%H%M%S)"
	# Remove the containers that is using the current volume
	./remove-containers-by-volume.sh ${VOLUME_NAME}
else
	echo "Volume $VOLUME_NAME does not exist, continuing to restoration."
fi

docker volume create --name "${VOLUME_NAME}"

# Move the data within BKP_OBJECT_PATH into the volume
docker container run --rm \
	-v ${VOLUME_NAME}:/data \
	-v $(dirname ${BKP_OBJECT_PATH}):/backup \
	alpine ash -c "rm -rf /data/* && cd /backup/ && BKP_OBJECT_DIRNAME=\$(tar -tzf $(basename ${BKP_OBJECT_PATH}) | head -1 | cut -f1 -d"/") && tar -xvzf $(basename ${BKP_OBJECT_PATH}) && mv \${BKP_OBJECT_DIRNAME}/* ../data/"
#	alpine ash -c "cd /backup/ && BKP_OBJECT_DIRNAME=`tar -tzf $(basename ${BKP_OBJECT_PATH}) | head -1 | cut -f1 -d"/"` && tar -xvzf $(basename ${BKP_OBJECT_PATH}) && mv ${BKP_OBJECT_DIRNAME}/* ../data/*"

# Remove the volume
# docker volume rm "${VOLUME_NAME}"

# Recreate the volume
# docker volume create --name "${VOLUME_NAME}"





