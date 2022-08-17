#!/bin/bash

############################################################
BASEDIR="$(cd $(dirname "$0") && pwd)"
JENKINS_HOME="$(dirname "$(cd $(dirname "$0") && pwd)")"
DOCKERFILE_LOC="${JENKINS_HOME}"

# Debugging script run context 
# echo "Script Directory: ${BASEDIR}"
# echo "Jenkins Home: ${JENKINS_HOME}"
############################################################
# Clean jenkins environment
cleanEnvironment() {
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

    # Verify image does not already exist
    docker rmi "${IMAGE_NAME}"
}
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

    # Get Jenkins user(s) from AWS Systems Manager Parameter Store
    # Run an aws command from a docker container and remove the container when finished
    # Prerequisite: Set up ~/.aws/credentials and ~/.aws/config for the root user
    CREDENTIAL="$(docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli ssm get-parameters --name 'JENKINS_ADMIN_PASS' --with-decryption --query Parameters[*].Value --output text --no-cli-pager)"  
    
    ## Get additional credentials
    GIT_TOKEN="$(docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli ssm get-parameters --name 'GIT_ACCESS_TOKEN' --with-decryption --query Parameters[*].Value --output text --no-cli-pager)"
    AWS_CLI_ACCESS_KEY_ID="$(docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli ssm get-parameters --name 'JENKINS-AWS-CLI-ACCESS-KEY-ID' --with-decryption --query Parameters[*].Value --output text --no-cli-pager)"
    AWS_CLI_SECRET_ACCESS_KEY="$(docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli ssm get-parameters --name 'JENKINS-AWS-CLI-SECRET-ACCESS-KEY' --with-decryption --query Parameters[*].Value --output text --no-cli-pager)"

    # Janky Workaround
    # Put secret(s) in temp text file and then pass the file in to docker run
    echo -e "JENKINS_ADMIN_PASSWORD=${CREDENTIAL}" > ./env.txt
    echo -e "GIT_ACCESS_TOKEN=${GIT_TOKEN}" >> ./env.txt

    # Run container 
    # docker run --name "${CONTAINER_NAME}" --detach -p 8080:8080 --env JENKINS_ADMIN_PASSWORD="${CREDENTIAL}" "${IMAGE_NAME}"
    docker run --name "${CONTAINER_NAME}" --detach -p 8080:8080 --env-file env.txt "${IMAGE_NAME}"

    # Delete Text File
    rm ./env.txt

    # Verify container is running
    docker ps -a
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

# Clean the environment
cleanEnvironment "${CONTAINER_TAG}" "${IMAGE_TAG}"

# Build the jenkins image
buildImage "${IMAGE_TAG}"

# Run the jenkins container
runJenkins "${CONTAINER_TAG}" "${IMAGE_TAG}"





