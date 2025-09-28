# Devcontainer image that uses the latest pack from the GitHub repo
# This builds from the latest commits rather than specific versions

ARG BASE_IMG=ghcr.io/joshuanianji/idris-2-docker/base:latest
FROM $BASE_IMG AS base

# =====
FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

# Install system dependencies required for pack
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
    git \
    make \
    gcc \
    libgmp-dev \
    curl \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

# Copy scheme and csv libraries from base image
COPY --from=base /usr/bin/scheme /usr/bin/scheme
COPY --from=base /root/scheme-lib/ /usr/lib/

# Set environment variables
ENV SCHEME=scheme

# install pack
RUN mkdir -p /opt/pack-installer && chown -R vscode:vscode /opt/pack-installer
USER vscode
WORKDIR /opt/pack-installer
RUN curl -o install.bash https://raw.githubusercontent.com/stefan-hoeck/idris2-pack/main/install.bash && \
    echo "scheme" | bash install.bash

ENV PATH="/home/vscode/.pack/bin:${PATH}"

# Install Idris2 LSP via pack
RUN echo "yes" | pack install-app idris2-lsp
