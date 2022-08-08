#!/bin/bash

############################################################
BASEDIR="$(cd $(dirname "$0") && pwd)"
JENKINS_HOME="$(dirname "$(cd $(dirname "$0") && pwd)")"
DOCKERFILE_LOC="${JENKINS_HOME}"

# Debugging script run context 
# echo "Script Directory: ${BASEDIR}"
# echo "Jenkins Home: ${JENKINS_HOME}"
############################################################
# Build Jenkins image 
buildImage() {
    # Set default image name/tag to jenkinsdev unless another option is provided
    if [[ -z $1 ]];
    then 
        IMAGE_NAME="jenkinsdev"
    else
        IMAGE_NAME="$1"
    fi

    # Verify image does not already exist
    docker rmi "${IMAGE_NAME}"

    # Build image
    docker build -t "${IMAGE_NAME}" "${DOCKERFILE_LOC}"

    # Verify image has been built
    docker images
}
############################################################
# Run Jenkins container
runJenkins() {
    # Set default container name/tag to jenkdev unless another option is provided
    if [[ -z $1 ]];
    then 
        CONTAINER_NAME="jenkdev"
    else
        CONTAINER_NAME="$1"
    fi

    # Set default image name/tag to jenkinsdev unless another option is provided
    if [[ -z $2 ]];
    then 
        IMAGE_NAME="jenkinsdev"
    else
        IMAGE_NAME="$2"
    fi

    # Verify container does not already exist by stopping and removing all inactive containers
    docker stop "${CONTAINER_NAME}"
    docker rm "$(docker ps -a -f status=exited -q)"

    # Run container 
    docker run --name "${CONTAINER_NAME}" --detach -p 8080:8080 "${IMAGE_NAME}"

    # Verify container is running
    docker ps -a
    ps -ef | grep 8080
}
############################################################
# Main

IMAGE_TAG="jenkinsdev"
CONTAINER_TAG="jenkdev"

# Process the input options. Add options as needed.

# Get the options
while getopts ":i:c:" option; do
    case $option in
        i) IMAGE_TAG="${OPTARG}";;
        c) CONTAINER_TAG="${OPTARG}";;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

echo "Image Tag: ${IMAGE_TAG}"
echo "Container Tag: ${CONTAINER_TAG}"

buildImage "${IMAGE_TAG}"
runJenkins "${CONTAINER_TAG}" "${IMAGE_TAG}"




