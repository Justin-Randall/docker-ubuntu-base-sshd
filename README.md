# Docker container using ubuntu-latest and running SSHD

Batch files and Dockerfile to create a container that will run sshd
from Ubuntu. A separate shell script, ```run.sh``` will detect a fresh
container and install ssh keys, setup sudoers and otherwise customize
the container for the local developer.

This is intended to be a very lightweight way to create a clean linux
dev environment for use with something like Visual Studio Code
Remote-SSH.

Note, if your dev system is also running an SSH server, the run script
will need to alter the port publication parameters.

```shell
docker run --detach --publish 22:22/tcp -it --name openssh-dev-base-container --security-opt seccomp=unconfined openssh-dev-base
```

specifically the `--publish 22:22/tcp` argument where the format is
`hostport:containerport`. See
[Docker run reference](https://docs.docker.com/engine/reference/run/) for details.

## Prerequisites

- Windows, Mac or Linux host
  - If you are on Windows, you should be using bash or [git-bash](https://git-scm.com/downloads) to execute the included scripts.
- [Docker](https://www.docker.com/products/docker-desktop)
  - Docker is container-based virtualization. It is NOT a virtual machine and does not
    impose the 30%+ overhead that VMs typically impose. If you are running it on
    Windows, WSL2 (Windows Subsystem for Linux) includes a full Linux kernel running
    in kernel space on Windows. The container runs natively like any other application,
    except it has complete isolation and its resources are assigned to it by the host
    operating system.
- An ssh client (comes with the git install on Windows, also should be included with
  recent builds of Windows 10)
  - `id_rsa.pub` exists at `HOME/.ssh/id_rsa.pub`
  - `id_rsa` is what you use to access git repos and exists at `HOME/.ssh/id_rsa`

    - ```shell
      ssh-keygen
      ```

      This should generate default a id_rsa and id_rsa.pub keypair. If you do not
      provide a password, then you can use ssh without having to enter a password
      on the remote host.

## Optional

- [ConEmu](https://conemu.github.io/) an excellent console emulator with tabs that handls SSH well
- ~/.ssh/sshconfig
- A shell script to initialize your dev environment located at `HOME/init-container.sh`
- A .gitconfig file at `HOME/.gitconfig`

## Installation

If you are reading this on Github, click on the big green button that says `Code`. In the drop down, select `Clone` and copy the text that is shown. Use that to clone the repo.

## Usage

```shell
./build.sh
./run.sh

ssh 127.0.0.1
```

When you want to tear down the container (note, this will also erase the contents of the container):

```shell
./kill.sh
```

### Options

The shell scripts honor some environment variables to override default
behavior.

```shell
export USERNAME=bart
export DOCKER_SSH_FORWARD_PORT=2222
```

Setting these two environment variables before executing

```shell
./run.sh
```

will tell the new container to create a user named `bart` that will use
your ssh credentials, and for the host to bind TCP port 2222 and forward
it to port 22 on the container (ssh). This is useful if an ssh server is
already listening on the docker host.

To connect to the container:

```shell
ssh -p 2222 bart@127.0.0.1
```

## Visual Studio Code setup

Since the Dockerfile and scripts have done all of the work for you,
navigate over to
[Visual Studio Code's guide to setting up Remote-SSH](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host )
and skip to step 2 in "Connect to a remote host" on the page.
