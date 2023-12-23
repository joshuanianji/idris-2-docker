# like base, we install scheme
FROM debian:bullseye as scheme-builder

WORKDIR /root

RUN apt-get update && \
    apt-get install -y git make gcc libncurses5-dev libncursesw5-dev libx11-dev libgmp-dev

COPY scripts/install-chezscheme-arch.sh ./install-chezscheme-arch.sh 

# check if system is arm based
# if so, install chez scheme from source

RUN if [ $(uname -m) = "aarch64" ] ; then ./install-chezscheme-arch.sh ; else apt-get install -y chezscheme ; fi
RUN which scheme

# copy csv* library to /root/move
# this makes it a bit easier for us to move the csv folder to other build steps, since it is necessary for scheme to run
RUN mkdir scheme-lib && cp -r /usr/lib/csv* /root/scheme-lib

FROM debian:bullseye as builder 

# LSP_VERSION is in the form "idris2-0.5.1", or "latest"
ARG IDRIS_LSP_VERSION=latest
ARG IDRIS_LSP_SHA

RUN apt-get update && \
    apt-get install -y git make gcc libgmp-dev curl

# copy scheme
COPY --from=scheme-builder /usr/bin/scheme /usr/bin/scheme
COPY --from=scheme-builder /root/scheme-lib/ /usr/lib/

# git clone idris2-lsp, as well as underlying Idris2 submodule
WORKDIR /build
# Using --recurse-submodules, we get the underlying idris2 repo in the recorded state (https://stackoverflow.com/a/3797061)
RUN if [ $IDRIS_LSP_VERSION = "latest" ] ; \ 
    then git clone https://github.com/idris-community/idris2-lsp.git && cd idris2-lsp && git checkout $IDRIS_LSP_SHA ; \
    else git clone --depth 1 --branch $IDRIS_LSP_VERSION https://github.com/idris-community/idris2-lsp.git ; \
    fi

# necessary environment variables for building Idris and the LSP
ENV PATH="/usr/local/lib/idris2/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib/idris2/lib:${LD_LIBRARY_PATH}"
ENV IDRIS2_PREFIX="/usr/local/lib/idris2"

COPY scripts/install-idris-lsp.sh ./install-idris-lsp.sh 
RUN ./install-idris-lsp.sh

FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

# idris2 + idris2-lsp compiled from source
COPY --from=builder /usr/local/lib/idris2 /usr/local/lib/idris2
# scheme + csv library
COPY --from=scheme-builder /usr/bin/scheme /usr/bin/scheme
COPY --from=scheme-builder /root/scheme-lib/ /usr/lib/ 

# set required environment variables
ENV PATH="/usr/local/lib/idris2/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib/idris2/lib:${LD_LIBRARY_PATH}"
ENV IDRIS2_PREFIX="/usr/local/lib/idris2"
