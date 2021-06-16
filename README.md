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
https://docs.docker.com/engine/reference/run/ for reference.

## Prerequisites

- Windows, Mac or Linux host
- [Docker](https://www.docker.com/products/docker-desktop)
  - Docker is container-based virtualization. It is NOT a virtual machine and does not
    impose the 30%+ overhead that VMs typically impose. If you are running it on
    Windows, WSL2 (Windows Subsystem for Linux) includes a full Linux kernel running
    in kernel space on Windows. The container runs natively like any other application,
    except it has complete isolation and its resources are assigned to it by the host
    operating system.
- `id_rsa.pub` exists at `HOME/.ssh/id_rsa.pub`
- `id_rsa` is what you use to access git repos and exists at `HOME/.ssh/id_rsa`

## Optional

- ~/.ssh/sshconfig
- A shell script to initialize your dev environment located at `HOME/init-container.sh`
- A .gitconfig file at `HOME/.gitconfig`

## Usage

```shell
git clone git@github.com:Justin-Randall/docker-ubuntu-base-sshd.git
./build.sh
./run.sh

ssh 127.0.0.1
```

When you want to tear down the container (note, this will destroy all
running containers):

```shell
./kill.sh
```

# Visual Studio Code setup
Since the Dockerfile and scripts have done all of the work for you,
navigate over to
[Visual Studio Code's guide to setting up Remote-SSH](https://code.visualstudio.com/docs/remote/ssh#_connect-to-a-remote-host )
and skip to step 2 in "Connect to a remote host" on the page.
