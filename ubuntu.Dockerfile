ARG IDRIS_VERSION=latest
ARG BASE_IMG=ghcr.io/joshuanianji/idris-2-docker/base:${IDRIS_VERSION}

FROM $BASE_IMG AS base

FROM ubuntu:20.04

# add idris2 and scheme from builder
COPY --from=base /root/.idris2 /root/.idris2
COPY --from=base /usr/bin/scheme /usr/bin/scheme
# copy csv* to /usr/lib
COPY --from=base /root/scheme-lib/ /usr/lib/ 

# add idris2 to path
ENV PATH="/root/.idris2/bin:${PATH}"

ENTRYPOINT ["idris2"]
