# Idris 2 Docker

Multi-arch, multi-distro Docker images for Idris 2, primarily aimed for devcontainers.

Architectures: `amd64`, `arm64`

Idris Versions: `v0.5.1`, `v0.6.0`, `v0.7.0`, `latest` (Up to date with [Idris2/main](https://github.com/idris-lang/Idris2/tree/main) - recompiled daily)

## Table of Contents

- [Idris 2 Docker](#idris-2-docker)
  - [Table of Contents](#table-of-contents)
  - [Motivation](#motivation)
  - [Images](#images)
  - [Example Project](#example-project)
  - [Usage](#usage)
    - [Devcontainer](#devcontainer)
    - [Command Line](#command-line)
    - [Base Image](#base-image)
  - [Running Locally](#running-locally)
    - [Build Latest](#build-latest)
    - [Build From a Tagged Release/SHA commit](#build-from-a-tagged-releasesha-commit)
  - [Credit](#credit)

## Motivation

Installing Idris2 is [quite time consuming](https://idris2.readthedocs.io/en/latest/tutorial/starting.html) and [not very intuitive](https://github.com/idris-lang/Idris2/issues/2404), [especially for Apple Silicon](https://www.reddit.com/r/Idris/comments/wyox7i/building_idris2_for_apple_silicon_as_of_august/). That presents quite a bottleneck for new users. This project aims to provide a quick and easy way to get started with Idris2 without having to go through the entire process on your own machine.

## Images

* [idris-2-docker/base](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fbase) - Base image with Idris2 installed from source.
* [idris-2-docker/devcontainer](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fdevcontainer) - Includes [Idris2 LSP](https://github.com/idris-community/idris2-lsp)
* [idris-2-docker/ubuntu](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fubuntu) - Ubuntu 20.04
* [idris-2-docker/debian](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fdebian) - Debian bullseye

## Example Project

An example Hello World project taken from the [Getting Started Guide](https://idris2.readthedocs.io/en/latest/tutorial/starting.html) can be found in [example](./example). It uses Idris 0.7.0. To start, clone this repo and open the example folder (not the root!) in VSCode.

```bash
git clone git@github.com:joshuanianji/idris-2-docker.git
cd idris-2-docker/example
code .
```

## Usage

### Devcontainer

Add devcontainers to your own project by copying the following contents to `Dockerfile` in the root of your project:

```dockerfile
FROM ghcr.io/joshuanianji/idris-2-docker/devcontainer:v0.7.0
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

You can also use one of the images as a base image for your own Dockerfile.

```dockerfile
FROM ghcr.io/joshuanianji/idris-2-docker/debian:v0.5.1

# ...
```

## Running Locally

To run the images locally, I recommend opening the workspace in the Devcontainer to provide a fully-featured development environment. I made a `scripts/build-image.py` which can build the base, debian, ubuntu or devcontainer from an idris version or a SHA commit.

### Build Latest

This is the default behaviour when running the script.

```bash
# builds base from latest commit on the Idris repo. Tag is base-latest
python scripts/build-image.py --image base
python scripts/build-image.py --image devcontainer --tag devcontainer-latest-test
```

### Build From a Tagged Release/SHA commit

```bash
python scripts/build-image.py --image base --version v0.6.0
python scripts/build-image.py --image base --sha 58e5d156621cfdd4c54df26abf7ac9620cfebdd8
python scripts/build-image.py --image devcontainer --version v0.6.0
```

## Credit

* [dgellow/idris-docker-image](https://github.com/dgellow/idris-docker-image) for giving me a starting point
* [YBogomolov's Gist](https://gist.github.com/YBogomolov/dc49c610cf7d92c60fb4678bae3ab753) for Devcontainer pointers
