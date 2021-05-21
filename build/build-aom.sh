#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = aom version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "aom"
checkStatus $? "create directory failed"
cd "aom/"
checkStatus $? "change directory failed"

# download source
git clone --depth=1 https://aomedia.googlesource.com/aom
checkStatus $? "git clone of aom failed"
cd "aom"
checkStatus $? "change directory failed"

# check out release
#git checkout tags/v$5
#checkStatus $? "checkout of aom release failed"

# prepare build
mkdir ../aom_build
checkStatus $? "create aom build directory failed"
cd ../aom_build
checkStatus $? "change directory to aom build failed"
cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DCONFIG_RUNTIME_CPU_DETECT=no -DENABLE_NEON=ON -DHAVE_NEON=1 -DENABLE_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-flto -O3" -DCMAKE_C_FLAGS="-flto -O3" -DCMAKE_C_FLAGS_INIT="-flto=8" ../aom/
checkStatus $? "configuration of aom failed"

# build
make -j $4
checkStatus $? "build of aom failed"

# install
make install
checkStatus $? "installation of aom failed"
