# Expects IDRIS_VERSION to NOT be `latest`
# But a tag of the form `v0.7.0`

ARG IDRIS_VERSION=0.7.0
ARG BASE_IMG=ghcr.io/joshuanianji/idris-2-docker/base:${IDRIS_VERSION}
FROM $BASE_IMG AS base

FROM debian:trixie AS rlwrap-builder
RUN apt-get update && \
    apt-get install -y \
    git \
    make \
    gcc \
    autotools-dev \
    libreadline-dev \
    autoconf

# Build rlwrap from source
WORKDIR /opt
RUN git clone https://github.com/hanslub42/rlwrap.git
WORKDIR /opt/rlwrap
RUN autoreconf --install
RUN ./configure --without-libptytty LDFLAGS='-static'
RUN make
RUN make install

FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

ARG IDRIS_VERSION
ARG BASE_IMG

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

# Copy statically built rlwrap from builder stage
COPY --from=rlwrap-builder /usr/local/bin/rlwrap /usr/local/bin/rlwrap

# Set environment variables
ENV SCHEME=scheme

# install pack
RUN mkdir -p /opt/pack-installer && chown -R vscode:vscode /opt/pack-installer
USER vscode
WORKDIR /opt/pack-installer
RUN curl -o install.bash https://raw.githubusercontent.com/stefan-hoeck/idris2-pack/main/install.bash && \
    echo "scheme" | bash install.bash

# Add pack to PATH
ENV PATH="/home/vscode/.local/bin:${PATH}"

# Install Idris2 LSP via pack
RUN echo "yes" | pack install-app idris2-lsp

# re-expose version information
ENV IDRIS_VERSION=$IDRIS_VERSION