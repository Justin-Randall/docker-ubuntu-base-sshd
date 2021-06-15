FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Grab curl and wget to bootstrap external repositories
RUN apt-get update
RUN apt-get install -y \
    curl \
    wget \
    sudo \
    net-tools \
    openssh-server \
    git 

# Workaround for executing sshd from the container
RUN mkdir /var/run/sshd

# OK, back to root and start the SSH server
USER root

# Open ports
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
