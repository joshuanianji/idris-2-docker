# Basically `base.Dockerfile` but takes in a SHA instead of a version
# This is so that we can use the latest commit on the idris-lang/idris2 repo
# separating this into a separate file so we can get better caching
# there is a lot of redundancy between this and base.Dockerfile, but I don't think it's worth it to try to abstract it out

FROM debian:bullseye AS scheme-builder

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

FROM debian:bullseye AS idris-builder

RUN apt-get update && \
    apt-get install -y git make gcc libgmp-dev curl

ENV DEBIAN_FRONTEND=noninteractive
# SHA of the latest commit on the idris-lang/idris2 repo
ARG IDRIS_SHA

COPY --from=scheme-builder /usr/bin/scheme /usr/bin/scheme
# copy csv* to /usr/lib, and also to /root/move for easier access for other build steps
COPY --from=scheme-builder /root/scheme-lib/ /usr/lib/
COPY --from=scheme-builder /root/scheme-lib/ /root/scheme-lib 

WORKDIR /root
RUN git clone https://github.com/idris-lang/Idris2.git && cd Idris2 && git checkout $IDRIS_SHA
WORKDIR /root/Idris2 
RUN make bootstrap SCHEME=scheme && make install

# add idris2 to path
ENV PATH="/root/.idris2/bin:${PATH}"
# add idris lib to LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH="/root/.idris2/lib:${LD_LIBRARY_PATH}"

# self-hosting (needed for Idris2 API)
# in my experience, the Idris2 API seems to still work without the self-hosting step
# At least, it builds the idris2-python correctly (although i haven't checked anything else)
# to be safe, I'll do this step anyway
# NOTE: not sure if the install-api transfers to the child images
RUN make clean && make all && make install
RUN make install-api

# re-expose version information
ENV IDRIS_SHA=$IDRIS_SHA
