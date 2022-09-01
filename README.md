# Idris 2 Docker

Multi-arch, multi-distro Docker images for Idris 2, primarily aimed for devcontainers.

## Images

- [idris-2-docker/devcontainer](https://github.com/joshuanianji/idris-2-docker/pkgs/container/idris-2-docker) - Debian bullseye built off of [Microsoft's Devcontainer Base image](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/debian)
- [idris-2-docker/ubuntu] - Ubuntu 20.04
- [idris-2-docker/debian] - Debian bullseye

## Usage

### Docker Image

```bash
docker run -it --rm ghcr.io/joshuanianji/idris-2-docker/ubuntu:v0.5.1 idris2 --version
v0.5.1

docker run -it --rm ghcr.io/joshuanianji/idris-2-docker/debian:v0.5.1 /bin/bash
$ idris2 --version
```

### Base Image

```dockerfile
FROM joshuanianji/idris-2-docker/debian:v0.5.1

# ...
```

### Devcontainer

Make a file called `Dockerfile` with the following contents:

```dockerfile
FROM joshuanianji/idris-2-docker/devcontainer:v0.5.1
```

Then, using Microsoft's Remote SSH tools, click "reopen in container" and choose the dockerfile.
