#!/usr/bin/bash
 
if [ -z "$USERNAME"]
then
    USERNAME=`whoami`
fi

if [ -z "$DOCKER_SSH_FORWARD_PORT" ]
then
    DOCKER_SSH_FORWARD_PORT=22
fi

docker run --detach --publish $DOCKER_SSH_FORWARD_PORT:22/tcp --name openssh-dev-base-container --security-opt seccomp=unconfined openssh-dev-base

# See if this is the first time this user is attempting to run this
# image.
ID=`docker exec openssh-dev-base-container sh -c "id -u ${USERNAME}"`
if [ $? == 1 ]
then
    echo "${USERNAME} not found. Running first time setup."
    ./lib/first-run.sh
fi

