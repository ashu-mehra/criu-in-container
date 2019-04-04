#!/bin/bash

ACMEAIR_CONTAINER_WORKDIR="/root"

DOCKER_NETWORK="acmeair-net"

MONGO_DB_IMAGE="mongo:latest"
ACMEAIR_DOCKER_IMAGE="acmeair_liberty:latest"
ACMEAIR_DOCKER_NEW_IMAGE="acmeair_liberty_checkpoint:latest"

MONGO_DB_CONTAINER="acmeair-db"
ACMEAIR_CONTAINER="acmeair-server"

