# IDRIS_VERSION is in the format "x.y.z" (e.g. "0.5.1") or "latest"
ARG IDRIS_VERSION=latest

FROM ghcr.io/joshuanianji/idris-2-docker/base:v${IDRIS_VERSION} as base

FROM debian:bullseye as builder 
# args are not shared between build stages
# https://github.com/moby/moby/issues/37345
ARG IDRIS_VERSION
ARG IDRIS_LSP_SHA

RUN apt-get update && \
    apt-get install -y git make gcc libgmp-dev curl

# add scheme from base
COPY --from=base /usr/bin/scheme /usr/bin/scheme
COPY --from=base /root/scheme-lib/ /usr/lib/

# git clone idris2-lsp, as well as underlying Idris2 submodule
WORKDIR /build
# Using --recurse-submodules, we get the underlying idris2 repo in the recorded state (https://stackoverflow.com/a/3797061)
RUN if [ $IDRIS_VERSION = "latest" ] ; \ 
    then git clone https://github.com/idris-community/idris2-lsp.git && cd idris2-lsp && git checkout $IDRIS_LSP_SHA ; \
    else git clone --depth 1 --branch "idris2-$IDRIS_VERSION" https://github.com/idris-community/idris2-lsp.git ; \
    fi

WORKDIR /build/idris2-lsp
RUN git submodule update --init --recursive
WORKDIR /build/idris2-lsp/Idris2
RUN make bootstrap SCHEME=scheme && make install PREFIX=/usr/local/lib/idris2
# Manual install of idris2-lsp 
# https://github.com/idris-community/idris2-lsp#manual-installation
RUN make install-with-src-libs PREFIX=/usr/local/lib/idris2
RUN make install-with-src-api PREFIX=/usr/local/lib/idris2
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

ENTRYPOINT ["idris2"]
