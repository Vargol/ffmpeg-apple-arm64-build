#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = openh264 version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "openh264"
checkStatus $? "create directory failed"
cd "openh264/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://github.com/cisco/openh264/archive/v$5.tar.gz
checkStatus $? "download of openh264 failed"

# unpack
tar -zxf "v$5.tar.gz"
checkStatus $? "unpack openh264 failed"
cd "openh264-$5/"
checkStatus $? "change directory failed"

# build
make PREFIX="$3" -j $4
checkStatus $? "build of openh264 failed"

# install
make install PREFIX="$3"
checkStatus $? "installation of openh264 failed"

# remove dynamic lib
rm $3/lib/libopenh264*.dylib
