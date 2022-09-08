# Idris 2 Docker

Multi-arch, multi-distro Docker images for Idris 2, primarily aimed for devcontainers.

Architectures: `amd64`, `arm64`

Idris Versions: `v0.5.0`, `v0.5.1`, `latest` (Up to date with [Idris2/main](https://github.com/idris-lang/Idris2/tree/main) - recompiled daily)

## Table of Contents

* [Usage](#usage)
  * [Try it out](#try-it-out)
    * [Requirements](#requirements)
  * [Devcontainer](#devcontainer)
  * [Command Line](#command-line)
  * [Base Image](#base-image)
* [Credit](#credit)

## Images

* [idris-2-docker/devcontainer](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fdevcontainer) - Debian bullseye built off of [Microsoft's Devcontainer Base image](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/debian)
* [idris-2-docker/ubuntu](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fubuntu) - Ubuntu 20.04
* [idris-2-docker/debian](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fdebian) - Debian bullseye

## Usage

### Try it out

If you want to try out a quick ready-to-use project, take a look at [Caleb's Wordle in Idris](https://github.com/calebji123/WordleInIdris). The devcontainer files are set up there and it's super fun to play around with!

#### Requirements

* A working instance of [Docker](https://docs.docker.com/get-docker/)
* [VSCode](https://code.visualstudio.com/download)
* [Remote Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension for VSCode

Clone the repo and open it in VSCode.

```bash
git clone https://github.com/calebji123/WordleInIdris.git
```

When prompted, click "Reopen in Container" and you're good to go!

### Devcontainer

Add devcontainers to your own project by copying the following contents to `Dockerfile` in the root of your project:

```dockerfile
FROM ghcr.io/joshuanianji/idris-2-docker/devcontainer:v0.5.1
```

Then, using Microsoft's Remote SSH tools, click "Reopen in container" and choose that Dockerfile.

### Command Line

You can also run the image directly from the command line.

```bash
docker run -it --rm ghcr.io/joshuanianji/idris-2-docker/ubuntu:v0.5.1 idris2 --version
Idris 2, version 0.5.1

docker run -it --rm --entrypoint /bin/bash ghcr.io/joshuanianji/idris-2-docker/debian:v0.5.1
$ idris2 --version
```

### Base Image

To build on top of my images, you can use it as a base image:

```dockerfile
FROM ghcr.io/joshuanianji/idris-2-docker/debian:v0.5.1

# ...
```

## Credit

* [dgellow/idris-docker-image](https://github.com/dgellow/idris-docker-image) for giving me a starting point
* [YBogomolov's Gist](https://gist.github.com/YBogomolov/dc49c610cf7d92c60fb4678bae3ab753) for Devcontainer pointers
