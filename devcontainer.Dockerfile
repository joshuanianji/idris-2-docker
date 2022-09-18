ARG IDRIS_VERSION=latest

FROM ghcr.io/joshuanianji/idris-2-docker/base:${IDRIS_VERSION} as base

# install idris2-lsp
WORKDIR /root
RUN git clone https://github.com/idris-community/idris2-lsp.git
WORKDIR /root/idris2-lsp
RUN git submodule update --init Idris2
WORKDIR /root/idris2-lsp/Idris2
RUN make clean
RUN make all
RUN make install
RUN make clean
RUN make all
RUN make install
RUN make install-with-src-libs
RUN make install-with-src-api
WORKDIR /root/idris2-lsp
RUN make install


FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye

# add idris2 and scheme from builder
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
