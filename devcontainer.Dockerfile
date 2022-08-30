FROM debian:bullseye as builder

ENV IDRIS2_CG racket
ENV DEBIAN_FRONTEND noninteractive
ARG IDRIS_VERSION=v0.5.1

WORKDIR /root

RUN apt-get update && \
    apt-get install -y git make gcc libncurses5-dev libncursesw5-dev libx11-dev

# Build chez scheme (from source)
# https://github.com/racket/ChezScheme/blob/master/BUILDING
RUN git clone https://github.com/racket/ChezScheme.git
WORKDIR /root/ChezScheme 
RUN git submodule init && git submodule update 
RUN  ./configure --pb && make tarm64le.bootquick
RUN make && make install

WORKDIR /root
RUN git clone --depth 1 --branch $IDRIS_VERSION https://github.com/idris-lang/Idris2.git
WORKDIR /root/Idris2 
RUN make bootstrap SCHEME=scheme
RUN make install

FROM mcr.microsoft.com/vscode/devcontainers/base:debian

ENV SCHEME=scheme

# add idris2 and scheme from builder
COPY --from=builder /root/.idris2 /root/.idris2
COPY --from=builder /usr/bin/scheme /usr/bin/scheme

# add idris2 to path
ENV PATH="/root/.idris2/bin:${PATH}"

ENTRYPOINT ["/root/.idris2/bin/idris2"]
