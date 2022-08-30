# installs chez scheme from source for aarch based systems
# https://github.com/racket/ChezScheme/blob/master/BUILDING

git clone --depth 1 https://github.com/racket/ChezScheme.git
cd ChezScheme 
git submodule init && git submodule update 
# get boot files
./configure --pb && make tarm64le.bootquick
# build scheme with thread support enabled
./configure --threads && make && make install