#!/bin/bash

source ./util.sh

PROJECT_DIR=`pwd`
DOCKERFILE_DIR="$PROJECT_DIR/liberty/docker"

function create_liberty_image() {
	if [ ! -f "${DOCKERFILE_DIR}/Dockerfile" ]; then
		echo "ERROR: Did not find Dockerfile for liberty"
		exit 1
	else
		pushd ${DOCKERFILE_DIR}
		echo "INFO: Pulling OpenJ9 nightly image"
		echo "CMD: docker pull adoptopenjdk/openjdk8-openj9:nightly"
		docker pull adoptopenjdk/openjdk8-openj9:nightly
		echo "CMD: docker build -q -t ${image} -f Dockerfile ."
		docker -q build -t "${image}" -f Dockerfile .
		popd
	fi
}

image=$1
check_image_exists ${image}
if [ $? -ne 0 ]; then
	echo "INFO: Liberty docker image ${image} not found, creating it"
	create_liberty_image
	check_image_exists ${image}
	if [ $? -eq 0 ]; then
		echo "INFO: Liberty docker image ${image} created successfully"
	else
		echo "ERROR: Failed to create Liberty docker image ${image}"
		exit 1
	fi
else
	echo "INFO: Liberty docker image ${image} already exists"
fi

