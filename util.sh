#!/bin/bash

# Usage: check_image_exists <repo>[:<tag>]
# eg: check_image_exists openj9:java8
# if "tag" is not passed as the argument, then "latest" is used as the tag.
function check_image_exists() {
	OIFS=$IFS
	IFS=":"; set $1
	declare image_repo=$1
	declare image_tag=$2
	IFS=$OIFS
	if [ -z ${image_tag} ]; then
		image_tag="latest"
	fi
	declare images_output=`docker images ${image_repo}:${image_tag}`
	if [[ ${images_output} =~ ${image_repo} && ${images_output} =~ ${image_tag} ]]; then
		return 0 
	else
		return 1
	fi
}

# Usage: check_container_running <image_name> [<container_name>]
# eg: check_container_running mongo:latest acmeair-db
function check_container_running() {
	declare image=$1
	declare container=$2
	output=`docker ps | grep "${image}"`
	if [[ $? -eq 0  &&  "${output}" =~ "${container}" ]]; then
		return 0
	else
		return 1
	fi
}
