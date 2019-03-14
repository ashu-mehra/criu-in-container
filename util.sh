#!/bin/bash

function check_image_exists() {
	OIFS=$IFS
	IFS=":"; set $1
	image_repo=$1
	image_tag=$2
	IFS=$OIFS
	if [ -z ${image_tag} ]; then
		image_tag="latest"
	fi
	images_output=`docker images ${image_repo}:${image_tag}`
	if [[ ${images_output} =~ ${image_repo} && ${images_output} =~ ${image_tag} ]]; then
		return 0 
	else
		return 1
	fi
}
