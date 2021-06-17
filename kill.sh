#!/usr/bin/bash

docker ps -a --filter name=openssh-dev-base --quiet | xargs -r docker rm -f
