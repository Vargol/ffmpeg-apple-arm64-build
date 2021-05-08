#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = pkg-config version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "pkg-config"
checkStatus $? "create directory failed"
cd "pkg-config/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://pkg-config.freedesktop.org/releases/pkg-config-$4.tar.gz
checkStatus $? "download of pkg-config failed"

# TODO: checksum validation (if available)

# unpack
tar -zxf "pkg-config-$4.tar.gz"
checkStatus $? "unpack pkg-config failed"
cd "pkg-config-$4/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --with-pc-path="$3/lib/pkgconfig" --with-internal-glib
checkStatus $? "configuration of pkg-config failed"

# build
make
checkStatus $? "build of pkg-config failed"

# install
make install
checkStatus $? "installation of pkg-config failed"
