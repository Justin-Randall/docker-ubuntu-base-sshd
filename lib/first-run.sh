#!/usr/bin/bash

# This is a one-time script that will:
#
# 1. Create a user in the container based on $USERNAME
# 2. Add your ssh keys and allow passwordless login.
# 3. Add your user account to /etc/sudoers with NOWPASSWD
# 4. Run a custom init-cointainer.sh if one is found in 
#    the user's home directory on the host running the container.
if [ -z "$USERNAME" ]
then
    USERNAME=`whoami`
fi

echo "Performing first time setup for ${USERNAME}"
echo "This script can only be executed ONCE against a newly created and running container."

rm -f ./id_rsa*

# Grab the user's local files to feed docker build
cp ~/.ssh/id_rsa.pub .
cp ~/.ssh/id_rsa .
chmod 0666 id_rsa
if [ -f ~/.ssh/config ]
then
    cp ~/.ssh/config sshconfig
else
    echo "StrictHostKeyChecking=no" >> sshconfig
    echo "UserKnownHostsFile=/dev/null" >> sshconfig
fi

if [ -f ~/.gitconfig ]
then
    cp ~/.gitconfig .
else
    touch .gitconfig
fi

if [ -f ~/init-container.sh ]
then
    cp ~/init-container.sh .
else
    echo "#!/usr/bin/env bash" >> ./init-container.sh
fi

function bail() {
    echo $1
    exit 1
}

function copyToContainer() {
    echo "copy ${1} to openssh-dev-base-container:${2}"
    docker cp $1 openssh-dev-base-container:$2 || bail "Could not copy $1 to $2"
}

function execInContainer() {
    docker exec openssh-dev-base-container sh -c "$1" || bail "Failed to execute: $1"    
}

# Add dev user
echo "add ${USERNAME} to the container"
execInContainer "useradd --create-home --shell /bin/bash ${USERNAME}"

# Setup sudoers
echo "grant ${USERNAME} sudo privileges"
execInContainer "usermod --append --groups sudo ${USERNAME}"
execInContainer "echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"

# ssh configuration
echo "set up ssh access"
execInContainer "mkdir -p /home/${USERNAME}/.ssh"
execInContainer "chown ${USERNAME}.${USERNAME} /home/${USERNAME}/.ssh"
copyToContainer sshconfig "/home/${USERNAME}/.ssh/config"
copyToContainer id_rsa.pub "/home/${USERNAME}/.ssh/authorized_keys"
copyToContainer id_rsa.pub "/home/${USERNAME}/.ssh/id_rsa.pub"
copyToContainer id_rsa "/home/${USERNAME}/.ssh/id_rsa"
execInContainer "chown -R ${USERNAME}.${USERNAME} /home/${USERNAME}/.ssh"
execInContainer "chmod 0644 /home/${USERNAME}/.ssh/authorized_keys"
execInContainer "chmod 0400 /home/${USERNAME}/.ssh/id_rsa.pub"
execInContainer "chmod 0400 /home/${USERNAME}/.ssh/id_rsa"

# run the user's custom init-container.sh
# docker cp init-container.sh openssh-dev-base-container:/home/${USERNAME}/init-container.sh || bail "Could not copy init-container.sh to /home/${USERNAME}/init-container.sh"
echo "install and run init-container.sh in the container, as ${USERNAME} in /home/${USERNAME}"
copyToContainer init-container.sh "/home/${USERNAME}/init-container.sh"
execInContainer "chmod +x /home/${USERNAME}/init-container.sh"
docker exec -u ${USERNAME} openssh-dev-base-container sh -c "cd ~ && ~/init-container.sh"

# clean up the local files
rm -f ./id_rsa*
rm -f ./.gitconfig
rm -f ./sshconfig
rm -f ./init-container.sh
