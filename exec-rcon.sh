#!/bin/bash

CONTAINER_NAME="docker-minecraft-server_mc"
CONTAINER_NAME="mcaws"
CONTAINER_NAME="docker-minecraft-server-mc-1"

docker exec ${CONTAINER_NAME} rcon-cli "$@"

