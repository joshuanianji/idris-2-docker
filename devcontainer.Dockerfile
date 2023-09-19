ARG IDRIS_VERSION=latest

FROM ghcr.io/joshuanianji/idris-2-docker/base:${IDRIS_VERSION} as base

FROM debian:bullseye as builder 
# IDRIS_LSP_VERSION is in the form "idris2-0.5.1", "idris2-0.6.0", or "latest"
ARG IDRIS_LSP_VERSION=latest
ARG IDRIS_LSP_SHA

RUN apt-get update && \
    apt-get install -y git make gcc libgmp-dev curl

# add scheme from base
COPY --from=base /usr/bin/scheme /usr/bin/scheme
COPY --from=base /root/scheme-lib/ /usr/lib/

# git clone idris2-lsp, as well as underlying Idris2 submodule
WORKDIR /build
# Using --recurse-submodules, we get the underlying idris2 repo in the recorded state (https://stackoverflow.com/a/3797061)
RUN if [ $IDRIS_LSP_VERSION = "latest" ] ; \ 
    then git clone https://github.com/idris-community/idris2-lsp.git && cd idris2-lsp && git checkout $IDRIS_LSP_SHA ; \
    else git clone --depth 1 --branch $IDRIS_LSP_VERSION https://github.com/idris-community/idris2-lsp.git ; \
    fi

WORKDIR /build/idris2-lsp
RUN git submodule update --init Idris2
WORKDIR /build/idris2-lsp/Idris2
RUN make bootstrap SCHEME=scheme PREFIX=/usr/local/lib/idris2 && make install PREFIX=/usr/local/lib/idris2

# ensure idris2 is in path
ENV PATH="/usr/local/lib/idris2/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib/idris2/lib:${LD_LIBRARY_PATH}"

RUN make clean
RUN make all
RUN make install
RUN make install-with-src-libs PREFIX=/usr/local/lib/idris2
RUN make install-with-src-api PREFIX=/usr/local/lib/idris2

# Manually install LSP library and idris2-lsp
WORKDIR /build/idris2-lsp
RUN git submodule update --init LSP-lib
WORKDIR /build/idris2-lsp/LSP-lib
RUN idris2 --install-with-src
WORKDIR /build/idris2-lsp
RUN make install PREFIX=/usr/local/lib/idris2

FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

# add idris2 and scheme from builder
COPY --from=builder /usr/local/lib/idris2 /usr/local/lib/idris2
COPY --from=base /usr/bin/scheme /usr/bin/scheme
# copy csv* to /usr/lib
COPY --from=base /root/scheme-lib/ /usr/lib/ 

# set new Idris2
ENV PATH="/usr/local/lib/idris2/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib/idris2/lib:${LD_LIBRARY_PATH}"

