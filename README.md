# Idris 2 Docker

Multi-arch, multi-distro Docker images for Idris 2, primarily aimed for devcontainers.

Architectures: `amd64`, `arm64`
Idris Versions: `v0.5.0`, `v0.5.1`, `latest` (Up to date with [Idris2/main](https://github.com/idris-lang/Idris2/tree/main))

## Images

- [idris-2-docker/devcontainer](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fdevcontainer) - Debian bullseye built off of [Microsoft's Devcontainer Base image](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/debian)
- [idris-2-docker/ubuntu](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fubuntu) - Ubuntu 20.04
- [idris-2-docker/debian](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker%2Fdebian) - Debian bullseye

## Usage

### Command Line

```bash
docker run -it --rm ghcr.io/joshuanianji/idris-2-docker/ubuntu:v0.5.1 idris2 --version
Idris 2, version 0.5.1

docker run -it --rm --entrypoint /bin/bash ghcr.io/joshuanianji/idris-2-docker/debian:v0.5.1
$ idris2 --version
```

### Base Image

```dockerfile
FROM ghcr.io/joshuanianji/idris-2-docker/debian:v0.5.1

# ...
```

### Devcontainer

Make a file called `Dockerfile` with the following contents:

```dockerfile
FROM ghcr.io/joshuanianji/idris-2-docker/devcontainer:v0.5.1
```

Then, using Microsoft's Remote SSH tools, click "reopen in container" and choose the dockerfile.
