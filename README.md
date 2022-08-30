# Idris 2 Docker

Docker images for Idris2 development. Aimed for both 

```
docker buildx build --push -f devcontainer.Dockerfile \
    --platform linux/amd64,linux/arm64 \
    --tag joshuanianji/idris-docker-test:latest .
```