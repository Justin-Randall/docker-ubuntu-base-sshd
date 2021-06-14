#!/usr/bin/bash
# usually rely in /usr/bin/env bash, but WSL2 users will have a hard time with it...

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
fi

if [ -f ~/init-container.sh ]
then
    cp ~/init-container.sh .
else
    echo "#!/usr/bin/env bash" >> ./init-container.sh
fi

# Create the container
docker build --build-arg user=$USERNAME -t openssh-dev-base .

# clean up the local files
rm -f ./id_rsa*
rm -f ./.gitconfig
rm -f ./sshconfig
rm -f ./init-container.sh
