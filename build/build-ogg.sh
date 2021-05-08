#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = vorbis version - unised get heads from git

# load functions
. $1/functions.sh

SOFTWARE=ogg

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir ${SOFTWARE}
checkStatus $? "create directory failed"
cd ${SOFTWARE} 
checkStatus $? "change directory failed"

# download source
git clone https://gitlab.xiph.org/xiph/ogg.git
checkStatus $? "download of ${SOFTWARE} failed"

cd "${SOFTWARE}/"
checkStatus $? "change directory failed"

# prepare build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DBUILD_SHARED_LIBS=OFF .
checkStatus $? "configuration of ${SOFTWARE} failed"

# build
make -j $4
checkStatus $? "build of ${SOFTWARE} failed"

# install
make install
checkStatus $? "installation of ${SOFTWARE} failed"
