FROM debian:bullseye as builder

ENV IDRIS2_CG racket
ENV DEBIAN_FRONTEND noninteractive
ARG IDRIS_VERSION=v0.5.1

WORKDIR /root

RUN apt-get update && \
    apt-get install -y racket git make gcc libc-dev libgmp3-dev
RUN git clone --depth 1 --branch $IDRIS_VERSION https://github.com/idris-lang/Idris2.git

RUN cd /root/Idris2 && make bootstrap-racket && make install

FROM mcr.microsoft.com/vscode/devcontainers/base:debian

# add idris2 from builder
COPY --from=builder /root/.idris2 /root/.idris2

# add idris2 to path
ENV PATH="/root/.idris2/bin:${PATH}"