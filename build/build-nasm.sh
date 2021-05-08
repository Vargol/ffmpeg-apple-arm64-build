#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = nasm version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "nasm"
checkStatus $? "create directory failed"
cd "nasm/"
checkStatus $? "change directory failed"

# download source
#curl -O -L http://www.nasm.us/pub/nasm/releasebuilds/$4/nasm-$4.tar.gz
cp $1/nasm-$4.tar.gz .
checkStatus $? "download of nasm failed"

# TODO: checksum validation (if available)

# unpack
tar -zxf "nasm-$4.tar.gz"
checkStatus $? "unpack nasm failed"
cd "nasm-$4/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3"
checkStatus $? "configuration of nasm failed"

# build
make
checkStatus $? "build of nasm failed"

# install
make install
checkStatus $? "installation of nasm failed"
