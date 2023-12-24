ARG IDRIS_VERSION=latest
ARG BASE_IMG=ghcr.io/joshuanianji/idris-2-docker/base:${IDRIS_VERSION}

# =====
# Idris Builder
# Rebuild with correct prefix. Somehow, building from scratch with a different prefix fails
FROM $BASE_IMG as idris-builder
ARG IDRIS_VERSION
ARG IDRIS_SHA

WORKDIR /build
RUN if [ $IDRIS_VERSION = "latest" ] ; \ 
    then git clone https://github.com/idris-lang/Idris2.git && cd Idris2 && git checkout $IDRIS_SHA ; \
    else git clone --depth 1 --branch $IDRIS_VERSION https://github.com/idris-lang/Idris2.git ; \
    fi
WORKDIR /build/Idris2
RUN make all PREFIX=/usr/local/lib/idris2
RUN make install PREFIX=/usr/local/lib/idris2

# =====
# LSP Builder
FROM debian:bullseye as lsp-builder 

RUN apt-get update && \
    apt-get install -y git make gcc libgmp-dev curl

# copy scheme + idris
COPY --from=idris-builder /usr/bin/scheme /usr/bin/scheme
COPY --from=idris-builder /root/scheme-lib/ /usr/lib/
COPY --from=idris-builder /usr/local/lib/idris2 /usr/local/lib/idris2

# necessary environment variables for building Idris and the LSP
ENV PATH="/usr/local/lib/idris2/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib/idris2/lib:${LD_LIBRARY_PATH}"
ENV IDRIS2_PREFIX="/usr/local/lib/idris2"

# LSP_VERSION is in the form "idris2-0.5.1", or "latest"
ARG IDRIS_LSP_VERSION=latest
ARG IDRIS_LSP_SHA

# git clone idris2-lsp, as well as underlying Idris2 submodule
WORKDIR /build
# Using --recurse-submodules, we get the underlying idris2 repo in the recorded state (https://stackoverflow.com/a/3797061)
RUN if [ $IDRIS_LSP_VERSION = "latest" ] ; \ 
    then git clone https://github.com/idris-community/idris2-lsp.git && cd idris2-lsp && git checkout $IDRIS_LSP_SHA ; \
    else git clone --depth 1 --branch $IDRIS_LSP_VERSION https://github.com/idris-community/idris2-lsp.git ; \
    fi
WORKDIR /build/idris2-lsp
RUN git submodule update --init --recursive

COPY scripts/install-idris-lsp.sh ./install-idris-lsp.sh 
RUN ./install-idris-lsp.sh

# =====
# Final Image
FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

ARG IDRIS_LSP_VERSION=latest
ARG IDRIS_LSP_SHA
ARG IDRIS_SHA

# idris2 + idris2-lsp compiled from source
COPY --from=lsp-builder /usr/local/lib/idris2 /usr/local/lib/idris2
# scheme + csv library
COPY --from=idris-builder /usr/bin/scheme /usr/bin/scheme
COPY --from=idris-builder /root/scheme-lib/ /usr/lib/ 

# set required environment variables
ENV PATH="/usr/local/lib/idris2/bin:${PATH}"
# LD_LIBRARY_PATH is only required for v0.5.1 and earlier
ENV LD_LIBRARY_PATH="/usr/local/lib/idris2/lib:${LD_LIBRARY_PATH}" 
ENV SCHEME=scheme

# re-expose IDRIS_LSP_VERSION and IDRIS_LSP_SHA args as env vars in the container
ENV IDRIS_LSP_VERSION=$IDRIS_LSP_VERSION
ENV IDRIS_LSP_SHA=$IDRIS_LSP_SHA
ENV IDRIS_SHA=$IDRIS_SHA

