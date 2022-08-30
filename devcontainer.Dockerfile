FROM debian:bullseye as scheme-builder

WORKDIR /root

RUN apt-get update && \
    apt-get install -y git make gcc libncurses5-dev libncursesw5-dev libx11-dev libgmp-dev

COPY scripts/install-chezscheme-arch.sh ./install-chezscheme-arch.sh 

# check if system is arm based
# if so, install chez scheme from source

RUN if [ $(uname -m) = "aarch64" ] ; then ./install-chezscheme-arch.sh ; else apt-get install -y chezscheme ; fi
RUN which scheme

FROM debian:bullseye as idris-builder

RUN apt-get update && \
    apt-get install -y git make gcc libgmp-dev

ENV IDRIS2_CG racket
ENV DEBIAN_FRONTEND noninteractive
ARG IDRIS_VERSION=v0.5.1

COPY --from=scheme-builder /usr/bin/scheme /usr/bin/scheme
COPY --from=scheme-builder /usr/lib/csv9.5.9.4 /usr/lib/csv9.5.9.4

# here are stuff we might need for scheme
# rm -rf /usr/lib/csv9.5.9.4
# rm -f /usr/bin/petite
# rm -f /usr/bin/scheme
# rm -f /usr/bin/scheme-script
# rm -f /usr/share/man/man1/petite.1
# rm -f /usr/share/man/man1/petite.1.gz
# rm -f /usr/share/man/man1/scheme.1
# rm -f /usr/share/man/man1/scheme.1.gz

WORKDIR /root
RUN git clone --depth 1 --branch $IDRIS_VERSION https://github.com/idris-lang/Idris2.git
WORKDIR /root/Idris2 
RUN make bootstrap SCHEME=scheme
RUN make install

FROM mcr.microsoft.com/vscode/devcontainers/base:debian

ENV SCHEME=scheme

# add idris2 and scheme from builder
COPY --from=idris-builder /root/.idris2 /root/.idris2
COPY --from=scheme-builder /usr/bin/scheme /usr/bin/scheme
COPY --from=scheme-builder /usr/lib/csv9.5.9.4 /usr/lib/csv9.5.9.4

# add idris2 to path
ENV PATH="/root/.idris2/bin:${PATH}"

ENTRYPOINT ["/root/.idris2/bin/idris2"]
