#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = libvpx version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "vpx"
checkStatus $? "create directory failed"
cd "vpx/"
checkStatus $? "change directory failed"

# download source

checkStatus $? "download of vpx failed"

# TODO: checksum validation (if available)
#git clone https://github.com/webmproject/libvpx.git
git clone https://chromium.googlesource.com/webm/libvpx 
cd "libvpx/"
checkStatus $? "change directory failed"

# prepare build
sed -i.original -e 's/march=armv8-a/march=armv8.4-a+dotprod/g' build/make/configure.sh 

./configure --prefix="$3" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --enable-vp8 \
                    --enable-vp9 \
                    --enable-internal-stats \
                    --enable-pic \
                    --enable-postproc \
                    --enable-multithread \
                    --enable-experimental \
                    --disable-install-docs \
                    --disable-debug-libs

checkStatus $? "configuration of vpx failed"


# build
make -j $4
checkStatus $? "build of vpx failed"

# install
make install
checkStatus $? "installation of vpx failed"
