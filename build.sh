#!/usr/bin/bash
# usually rely in /usr/bin/env bash, but WSL2 users will have a hard time with it...

# Create the container
docker build -t openssh-dev-base .
