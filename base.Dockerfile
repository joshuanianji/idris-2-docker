FROM debian:bullseye as scheme-builder

WORKDIR /root

RUN apt-get update && \
    apt-get install -y git make gcc libncurses5-dev libncursesw5-dev libx11-dev libgmp-dev

COPY scripts/install-chezscheme-arch.sh ./install-chezscheme-arch.sh 

# check if system is arm based
# if so, install chez scheme from source

RUN if [ $(uname -m) = "aarch64" ] ; then ./install-chezscheme-arch.sh ; else apt-get install -y chezscheme ; fi
RUN which scheme

# copy csv9.5* to /root/move
# this makes it a bit easier for us to move the csv folder to other build steps, since it is necessary for scheme to run
RUN mkdir scheme-lib && cp -r /usr/lib/csv9.5* /root/scheme-lib

FROM debian:bullseye as idris-builder

RUN apt-get update && \
    apt-get install -y git make gcc libgmp-dev curl

ENV DEBIAN_FRONTEND noninteractive
ARG IDRIS_VERSION
# SHA of the latest commit on the idris-lang/idris2 repo
ARG IDRIS_SHA

COPY --from=scheme-builder /usr/bin/scheme /usr/bin/scheme
# copy csv9.5* to /usr/lib, and also to /root/move for easier access for other build steps
COPY --from=scheme-builder /root/scheme-lib/ /usr/lib/
COPY --from=scheme-builder /root/scheme-lib/ /root/scheme-lib 

WORKDIR /root

RUN git clone https://github.com/idris-community/idris2-lsp.git # Clone this repository
WORKDIR /root/idris2-lsp
RUN git submodule update --init Idris2 # Get the associated Idris commit
WORKDIR /root/idris2-lsp/Idris2 # Change into the Idris2 directory
RUN make bootstrap SCHEME=scheme # Boostrap Idris
RUN make install # Install Idris
# If needed, modify your shell files to ensure ~/.idris2/bin is in your PATH
RUN make clean # Clean Idris
RUN make all # Build Idris
RUN make install # Install Idris
RUN make install-with-src-libs # Install sources for libraries
RUN make install-with-src-api # Install the API with sources
WORKDIR /root/idris2-lsp # Go back to the idris2-lsp directory
RUN make install # Install idris2-lsp

# these things aren't strictly necessary for a functioning base image, 
# but they make it possible for us to test the image 

# add idris2 to path
ENV PATH="/root/.idris2/bin:${PATH}"
# add idris lib to LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH="/root/.idris2/lib:${LD_LIBRARY_PATH}"
