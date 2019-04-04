#!/bin/bash

source ./util.sh
source ./common_env_vars.sh

PROJECT_DIR=`pwd`
WORKDIR=${PROJECT_DIR}/temp
ACMEAIR_ROOT_DIR=${WORKDIR}/acmeair

function cleanup() {
	declare clean_images=$1
	echo "INFO: Cleanup - Started"
	echo "INFO: Cleaning running containers"
	echo "CMD: docker stop ${ACMEAIR_CONTAINER} ${MONGO_DB_CONTAINER} &> /dev/null"

	docker stop "${ACMEAIR_CONTAINER}" "${MONGO_DB_CONTAINER}" &> /dev/null

	echo "CMD: docker rm "${ACMEAIR_CONTAINER}" "${MONGO_DB_CONTAINER}" &> /dev/null"

	docker rm "${MONGO_DB_CONTAINER}" &> /dev/null
	docker rm "${ACMEAIR_CONTAINER}" &> /dev/null

	echo "INFO: Cleaning running containers - Done"
	echo "INFO: Removing docker network \"${DOCKER_NETWORK}\""
	echo "CMD: docker network rm "${DOCKER_NETWORK}" &> /dev/null"

	docker network rm "${DOCKER_NETWORK}" &> /dev/null

	echo "INFO: Removing docker network - Done"

	if [ ! -z "${clean_images}" ]; then
		echo "INFO: Removing acmeair container image"
		echo "CMD: docker rmi "${ACMEAIR_DOCKER_IMAGE}" &> /dev/null"

		docker rmi "${ACMEAIR_DOCKER_IMAGE}" &> /dev/null

		echo "CMD: docker rmi "${ACMEAIR_DOCKER_NEW_IMAGE}" &> /dev/null"

		docker rmi "${ACMEAIR_DOCKER_NEW_IMAGE}" &> /dev/null

		echo "INFO: Removing acmeair container image - Done"
	fi
	echo "INFO: Cleanup - Done"
}

function create_acmeair_server_image() {
	if [ ! -d "${ACMEAIR_ROOT_DIR}" ]; then
		echo "INFO:Cloning acmeair setup"
		echo "CMD: git clone --depth 1 git@github.com:ashu-mehra/acmeair.git" 

		git clone --depth 1 "git@github.com:ashu-mehra/acmeair.git" "${ACMEAIR_ROOT_DIR}"

		echo "INFO: Cloning acmeair setup - Done"
	else
		echo "INFO: acmeair directory already exists - skip cloning"
	fi

	declare war_location=`find "${ACMEAIR_ROOT_DIR}" -name "acmeair-webapp*SNAPSHOT.war"`
	if [ -z "${war_location}" ]; then
		if [ -z "${JAVA_HOME}" ]; then
			echo "ERROR: JAVA_HOME not set"
			exit 1
		fi

		pushd "${ACMEAIR_ROOT_DIR}" &> /dev/null
		which gradle &>/dev/null
		if [ $? -eq 1 ]; then
			echo "ERROR: gradle not found on PATH"
			exit 1
		fi

		echo "INFO: Building acmeair"
		gradle build
		if [ $? -eq 0 ]; then
			echo "INFO: Building acmeair - Done"
		else
			echo "ERROR: Buildling acmeair - Failed"
			exit 1
		fi
		popd &> /dev/null
	else
		echo "INFO: acmeair application war file `basename "${war_location}"` already exists, skip building it"
	fi

	"${PROJECT_DIR}"/create_liberty_image.sh websphere-liberty:openj9-nightly

	# sed -i 's/websphere-liberty:kernel/websphere-liberty:openj9-nightly/g' "${ACMEAIR_ROOT_DIR}"/acmeair-webapp/Dockerfile

	echo "INFO: Building acmeair docker image"
	pushd "${ACMEAIR_ROOT_DIR}"/acmeair-webapp &> /dev/null
	echo "CMD: docker build -t "${ACMEAIR_DOCKER_IMAGE}" -f "${ACMEAIR_ROOT_DIR}"/acmeair-webapp/Dockerfile ."

	docker build -t "${ACMEAIR_DOCKER_IMAGE}" -f "${ACMEAIR_ROOT_DIR}"/acmeair-webapp/Dockerfile .

	popd &> /dev/null
	if [ $? -eq 0 ]; then
		# Verify the image is created

		check_image_exists "${ACMEAIR_DOCKER_IMAGE}"

		if [ $? -eq 0 ]; then
			echo "INFO: Building acmeair docker image - Done"
		else
			echo "ERROR: Building acmeair docker image completed but failed to find the docker image"
			exit 1;
		fi
	else
		echo "ERROR: Building acmeair docker image - Failed"
		exit 1
	fi
}

function setup_docker_network() {
	declare network
	network=`docker network ls | grep "${DOCKER_NETWORK}"`
	if [ $? -eq 0 ]; then
		# network already exists - check network type and subnet
		declare nettype=`echo "${network}" | awk '{ print $3 }'`
		if [[ $nettype =~ "bridge" ]]; then
			echo "INFO: Network \"${DOCKER_NETWORK}\" is of type \"${nettype}\""
		else
			echo "INFO: Network \"${DOCKER_NETWORK}\" is of type \"${nettype}\", expected \"bridge\" type"
			exit 1
		fi
	else
		echo "INFO: Creating docker network \"${DOCKER_NETWORK}\" of type \"bridge\""
		echo "CMD: docker network create --driver bridge --subnet="172.28.0.0/16" ${DOCKER_NETWORK}"

		docker network create --driver bridge --subnet='172.28.0.0/16' "${DOCKER_NETWORK}"

		echo "INFO: Creating docker network \"${DOCKER_NETWORK}\" of type \"bridge\" - Done"
	fi
}

function setup_container_images() {
	echo "INFO: Pulling ${MONGO_DB_IMAGE} image"

	docker pull "${MONGO_DB_IMAGE}"

	echo "INFO: Pulling ${MONGO_DB_IMAGE} image - Done"

	check_image_exists "${ACMEAIR_DOCKER_IMAGE}"
	if [ $? -ne 0 ] || [ "${build_docker_image}" == "1" ]; then
		create_acmeair_server_image
	fi
}


# execution starts from here
for i in "$@"; do
	case $i in
		-h | --help )
			usage
			;;
		-c | --cleanup)
			cleanup
			;;
		-a | --cleanup-all)
			cleanup 1 # clean existing docker images as well
			;;
		-f | --force-build-image)
			build_docker_image=1
			;;
	esac
done

cleanup

if [ ! -d "${WORKDIR}" ]; then
	mkdir "${WORKDIR}"
fi

setup_docker_network
setup_container_images

