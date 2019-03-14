#!/bin/bash

ACMEAIR_CONTAINER_WORKDIR="/root"

DOCKER_NETWORK="acmeair-net"

MONGO_DB_IMAGE="mongo:latest"
ACMEAIR_DOCKER_IMAGE="acmeair_liberty:latest"
ACMEAIR_DOCKER_NEW_IMAGE="acmeair_liberty_checkpoint:latest"

MONGO_DB_CONTAINER="acmeair-db"
ACMEAIR_CONTAINER="acmeair-server"

CRIU_DUMP_LOGFILE="dump.log"
CRIU_RESTORE_LOGFILE="restore.log"

CRIU_CHECKPOINT_SUCCESS_MSG="Checkpoint success"
CRIU_CHECKPOINT_FAILED_MSG="Checkpoint failed"
