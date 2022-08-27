FROM ubuntu:latest

ENV IDRIS2_CG racket
ENV DEBIAN_FRONTEND noninteractive
ARG IDRIS_VERSION=v0.3.0

WORKDIR /root

RUN apt-get update && \
    apt-get install -y racket git make gcc libc-dev
RUN git clone -b ${VERSION} --depth 1 https://github.com/idris-lang/Idris2.git && \
    cd ./Idris2 && \
    make bootstrap-racket && \
    make install
