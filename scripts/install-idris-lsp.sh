#!/bin/bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

# Given a cloned idris LSP repo, install the lsp server
# distinguishes between the "old" repo (pre 0.5.1) and the new one

# Also assumes that PATH and LD_LIBRARY_PATH are set correctly


if [ -z ${IDRIS_LSP_VERSION+x} ]; then 
    echo "IDRIS LSP VAR IS UNSET!";
    exit 1;
else 
    echo "LSP Version is set to '$IDRIS_LSP_VERSION'"; 
fi

# Reinstall Idris2
# https://github.com/idris-community/idris2-lsp/tree/idris2-0.6.0
# I think this is similar across all versions, but I need to test with 0.4.0 and 0.5.1
cd /build/idris2-lsp/Idris2
make bootstrap SCHEME=scheme PREFIX=/usr/local/lib/idris2 
make install PREFIX=/usr/local/lib/idris2

make clean PREFIX=/usr/local/lib/idris2
make all PREFIX=/usr/local/lib/idris2
make install PREFIX=/usr/local/lib/idris2
make install-with-src-libs PREFIX=/usr/local/lib/idris2
make install-with-src-api PREFIX=/usr/local/lib/idris2

# check if the version is "idris2-0.4.0" or "idris2-0.5.1"
# these are the "older" supported versions, before the idris2-lsp repo was split a reusable LSP-lib
if  [[ $IDRIS_LSP_VERSION == "idris2-0.4.0" ]] || 
    [[ $IDRIS_LSP_VERSION == "idris2-0.5.1" ]] || 
    [[ $IDRIS_LSP_VERSION == "idris2-0.6.0" ]]; then
    echo "Installing older version of idris2-lsp"

    # Manual install of idris2-lsp
    cd /build/idris2-lsp
    make install PREFIX=/usr/local/lib/idris2
else 
    # if the idris version is not one of the "old" ones, it is either a newer version (0.6.0 and up) or "latest"d
    echo "Installing newer version of idris2-lsp"

    # Manually install LSP library and idris2-lsp
    cd /build/idris2-lsp/LSP-lib
    idris2 --install-with-src
    cd /build/idris2-lsp
    make install PREFIX=/usr/local/lib/idris2
fi

echo "Idris2 LSP installed successfully"

