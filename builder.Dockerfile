FROM ubuntu:latest

ENV IDRIS2_CG racket
ENV DEBIAN_FRONTEND noninteractive
ARG IDRIS_VERSION=v0.5.1

WORKDIR /root

RUN apt-get update && \
    apt-get install -y racket git make gcc libc-dev libgmp3-dev
RUN git clone --depth 1 --branch $IDRIS_VERSION https://github.com/idris-lang/Idris2.git

RUN cd /root/Idris2 && make bootstrap-racket && make install

# add idris2 to path
ENV PATH="/root/.idris2/bin:${PATH}"