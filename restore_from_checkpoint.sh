#!/bin/bash

source ./util.sh
source ./common_env_vars.sh

check_image_exists "${ACMEAIR_DOCKER_NEW_IMAGE}"
if [ $? -ne 0 ]; then
	echo "ERROR: Did not find docker image \"${ACMEAIR_DOCKER_NEW_IMAGE}\"."
	exit 1
fi

check_container_running "${MONGO_DB_IMAGE}" "${MONGO_DB_CONTAINER}"
if [ $? -ne 0 ]; then
	echo "ERROR: Did not find mongo db container running."
	exit 1
fi

# start new container
echo "INFO: Starting container using image "

echo "CMD: docker run --name="${ACMEAIR_CONTAINER}" --privileged -d --entrypoint=criu -p '80:80' --network="${DOCKER_NETWORK}" --ip='172.28.0.3' -e MONGO_HOST="${MONGO_DB_CONTAINER}" acmeair_liberty_checkpoint restore --tcp-established -j -v4 -o "${ACMEAIR_CONTAINER_WORKDIR}"/"${CRIU_RESTORE_LOGFILE}""

acmeair_server=`docker run --name="${ACMEAIR_CONTAINER}" --privileged -d --entrypoint=criu -p '80:80' --network="${DOCKER_NETWORK}" --ip='172.28.0.3' -e MONGO_HOST="${MONGO_DB_CONTAINER}" "${ACMEAIR_DOCKER_NEW_IMAGE}" restore --tcp-established -j -v4 -o "${ACMEAIR_CONTAINER_WORKDIR}"/"${CRIU_RESTORE_LOGFILE}"`

echo "INFO: Acmeair server container id ${acmeair_server}"
sleep 5s
docker cp "${ACMEAIR_CONTAINER}":"${ACMEAIR_CONTAINER_WORKDIR}"/"${CRIU_RESTORE_LOGFILE}" .
echo "INFO: Done"
