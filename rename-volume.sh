#!/bin/bash

DisplayHelp() {
    echo "What it does: It renames a docker volume to a new name"
    echo "Usage: $0 <current volume name> <new volume name>"
}

if [ -z $1 ] || [ -z $2 ]; then 
    DisplayHelp 
    exit
fi

CUR_VOLUME=$1
NEW_VOLUME=$2

docker volume inspect ${CUR_VOLUME} > /dev/null
if [ ! $? -eq 0 ]; then
    echo "Error: The target volume '${CUR_VOLUME}' does not exist. Aborting."
    exit 1
fi 

echo "Changing docker volume '${CUR_VOLUME}' to '${NEW_VOLUME}'"

# Initialize the new volume
docker volume create --name ${NEW_VOLUME}

# Copy the old volume's data into the new volume
docker container run --rm -it \
	-v ${CUR_VOLUME}:/from \
	-v ${NEW_VOLUME}:/to \
	alpine ash -c "cd /from ; cp -av . /to"

# Remove the containers that is owned by the volume
./remove-containers-by-volume.sh ${CUR_VOLUME}

# Remove the old volume
docker volume rm ${CUR_VOLUME}

echo "Docker volume name changed"

