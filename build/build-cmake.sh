#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = cmake major version
# $6 = cmake full version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "cmake"
checkStatus $? "create directory failed"
cd "cmake/"
checkStatus $? "change directory failed"

# download source
curl -O https://cmake.org/files/v$5/cmake-$6.tar.gz
checkStatus $? "download of cmake failed"

# TODO: checksum validation (if available)

# unpack
tar -zxf "cmake-$6.tar.gz"
checkStatus $? "unpack of cmake failed"
cd "cmake-$6/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --parallel="$4"
checkStatus $? "configuration of cmake failed"

# build
make -j $4
checkStatus $? "build of cmake failed"

# install
make install
checkStatus $? "installation of cmake failed"
