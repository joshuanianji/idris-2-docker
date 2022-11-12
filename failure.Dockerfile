ARG IDRIS_VERSION=latest

FROM ghcr.io/joshuanianji/idris-2-docker/base:${IDRIS_VERSION} as base

FROM debian:latest

# add idris2 and scheme from builder
COPY --from=base /root/.idris2 /usr/local/lib/idris2
COPY --from=base /usr/bin/scheme /usr/bin/scheme
# copy csv9.5* to /usr/lib
COPY --from=base /root/scheme-lib/ /usr/lib/

ENV PATH="/usr/local/lib/idris2/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib/idris2/lib:${LD_LIBRARY_PATH}"

RUN apt-get update \
    && apt-get -y install rlwrap \
    && apt-get clean 

# This command won't output anything when you build with buildkit
RUN idris2 --version
