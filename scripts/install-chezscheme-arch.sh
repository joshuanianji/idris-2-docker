# installs chez scheme from source for aarch based systems
# https://github.com/racket/ChezScheme/blob/master/BUILDING

git clone --depth 1 https://github.com/racket/ChezScheme.git
cd ChezScheme 
git submodule init && git submodule update 

# Install for arm
# https://github.com/racket/ChezScheme/blob/05eabab8f4e590387a00af0841e24650494d806d/.github/workflows/build.yml#L40-L62
MACH=tarm64le

# get boot files
./configure --pb -m=$MACH && make ${MACH}.bootquick
# build scheme with thread support enabled
./configure --threads -m=$MACH && make -j$(($(nproc)+1)) -l$(nproc) && make install
