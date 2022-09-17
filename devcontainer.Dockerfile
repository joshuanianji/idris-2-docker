ARG IDRIS_VERSION=latest

FROM ghcr.io/joshuanianji/idris-2-docker/base:${IDRIS_VERSION} as base

FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

# add idris2, idris2-lsp and scheme from builder
COPY --from=base /root/.idris2 /root/.idris2
COPY --from=base /usr/bin/scheme /usr/bin/scheme
# copy csv9.5* to /usr/lib
COPY --from=base /root/scheme-lib/ /usr/lib/ 

# add idris2 to path
ENV PATH="/root/.idris2/bin:${PATH}"
# add idris lib to LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH="/root/.idris2/lib:${LD_LIBRARY_PATH}"
# Also make idris available via `idris`, so the idris extension can find it
# https://gist.github.com/YBogomolov/dc49c610cf7d92c60fb4678bae3ab753#file-dockerfile-L21
RUN ln -s /root/.idris2/bin/idris2 /bin/idris

ENTRYPOINT ["idris2"]
