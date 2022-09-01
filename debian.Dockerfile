ARG IDRIS_VERSION=latest

FROM ghcr.io/joshuanianji/idris-2-docker/base:${IDRIS_VERSION} as base

FROM debian:bullseye

# add idris2 and scheme from builder
COPY --from=base /root/.idris2 /root/.idris2
COPY --from=base /usr/bin/scheme /usr/bin/scheme
# copy csv9.5* to /usr/lib
COPY --from=base /root/scheme-lib/ /usr/lib/ 

# add idris2 to path
ENV PATH="/root/.idris2/bin:${PATH}"

ENTRYPOINT ["/root/.idris2/bin/idris2"]
