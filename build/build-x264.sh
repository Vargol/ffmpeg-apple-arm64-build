#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "x264"
checkStatus $? "create directory failed"
cd "x264/"
checkStatus $? "change directory failed"

# download source
curl -o x264-master.tar.gz -O -L https://github.com/mirror/x264/archive/master.tar.gz
checkStatus $? "download of x264 failed"

# TODO: checksum validation (if available)

# unpack
tar -zxf "x264-master.tar.gz"
checkStatus $? "unpack x264 failed"
cd "x264-master/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-static
checkStatus $? "configuration of x264 failed"

# build
make -j $4
checkStatus $? "build of x264 failed"

# install
make install
checkStatus $? "installation of x264 failed"
