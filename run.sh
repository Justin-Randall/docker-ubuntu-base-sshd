#!/usr/bin/bash

# Note, if you are running an ssh server locally, this is not going
# to work. This is intended for dev machines that are not listening
# on port 22. The -p parameter maps the container's port 22 (ssh)
# to the local host so you can simply 'ssh localhost'
docker run --rm --detach --publish 22:22/tcp -it --name openssh-dev-base-container --security-opt seccomp=unconfined openssh-dev-base
