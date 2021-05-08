#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = opus version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "opus"
checkStatus $? "create directory failed"
cd "opus/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://archive.mozilla.org/pub/opus/opus-$5.tar.gz
checkStatus $? "download of opus failed"

# unpack
tar -zxf "opus-$5.tar.gz"
checkStatus $? "unpack opus failed"
cd "opus-$5/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no
checkStatus $? "configuration of opus failed"

# build
make -j $4
checkStatus $? "build of opus failed"

# install
make install
checkStatus $? "installation of opus failed"
