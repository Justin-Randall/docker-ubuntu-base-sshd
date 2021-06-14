FROM ubuntu:latest

ARG user
ENV user_name=${user}
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

# Add dev user
RUN useradd --create-home --shell /bin/bash ${user_name}
RUN usermod --append --groups sudo ${user_name}

# Setup sudoers
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Setup ssh keys and config so dev user can connect
RUN mkdir -p /home/${user_name}/.ssh
RUN chown ${user_name}.${user_name} /home/${user_name}/.ssh
COPY sshconfig /home/${user_name}/.ssh/config
COPY id_rsa.pub /home/${user_name}/.ssh/authorized_keys
COPY id_rsa.pub /home/${user_name}/.ssh/id_rsa.pub
COPY id_rsa /home/${user_name}/.ssh/id_rsa
RUN chmod 0644 /home/${user_name}/.ssh/authorized_keys
RUN chmod 0400 /home/${user_name}/.ssh/id_rsa.pub
RUN chmod 0400 /home/${user_name}/.ssh/id_rsa

# Going to run some commands in user space
USER ${user_name}

# Horrible hactacular way to get around .bashrc evaluation during a 
# Dockerfile build
WORKDIR /home/${user_name}
SHELL ["/bin/bash", "-c"]
# Run any initial setup required based on user's custom script
COPY init-container.sh /home/${user_name}/init-container.sh

# Grab .gitconfig
COPY .gitconfig /home/${user_name}/.gitconfig
RUN ~/init-container.sh

# OK, back to root and start the SSH server
USER root

# Open ports
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
