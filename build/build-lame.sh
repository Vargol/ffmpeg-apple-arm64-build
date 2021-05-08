#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = lame version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "lame"
checkStatus $? "create directory failed"
cd "lame/"
checkStatus $? "change directory failed"

# download source
curl -O https://netcologne.dl.sourceforge.net/project/lame/lame/$4/lame-$4.tar.gz
checkStatus $? "download of lame failed"

# TODO: checksum validation (if available)

# unpack
tar -zxf "lame-$4.tar.gz"
checkStatus $? "unpack lame failed"
cd "lame-$4/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no
checkStatus $? "configuration of lame failed"

# build
make
checkStatus $? "build of lame failed"

# install
make install
checkStatus $? "installation of lame failed"
