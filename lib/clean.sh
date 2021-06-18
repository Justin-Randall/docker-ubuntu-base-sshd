#!/usr/bin/bash

docker ps --filter name=openssh-dev-base --quiet | xargs -r docker rm -f
docker builder prune -af