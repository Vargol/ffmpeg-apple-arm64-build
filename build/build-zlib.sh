#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = vorbis version - unused get heads from git

# load functions
. $1/functions.sh

SOFTWARE=zlib

make_directories() {

  # start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir ${SOFTWARE}
  checkStatus $? "create directory failed"
  cd ${SOFTWARE}
  checkStatus $? "change directory failed"
  mkdir build-${SOFTWARE}
  checkStatus $? "create directory failed"
  cd build-${SOFTWARE}
  checkStatus $? "change directory failed"

}

download_code () {

  cd "$2/${SOFTWARE}"
  checkStatus $? "change directory failed"
  # download source
  #git clone --branch zconf.h_fix https://github.com/cmake-remake/zlib.git
  git clone https://github.com/madler/zlib.git
  #git clone --branch v1.3.1  https://github.com/madler/zlib.git 
  checkStatus $? "download of ${SOFTWARE} failed"

}

configure_build () {

set -x

  cd "$2/${SOFTWARE}/build-${SOFTWARE}/"
  checkStatus $? "change directory failed"

  # prepare build
  #CFLAGS="${CFLAGS} -D_LARGEFILE64_SOURCE=1" cmake --trace-expand -DCMAKE_INSTALL_PREFIX:PATH=$3 -DINSTALL_PKGCONFIG_DIR=$3/lib/pkgconfig -DENABLE_SHARED=NO ../${SOFTWARE}
  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DINSTALL_PKGCONFIG_DIR=$3/lib/pkgconfig -DENABLE_SHARED=NO ../${SOFTWARE}
  checkStatus $? "configuration of ${SOFTWARE} failed"

}

make_clean() {

  cd "$2/${SOFTWARE}/build-${SOFTWARE}/"
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"


}

make_compile () {

  cd "$2/${SOFTWARE}/build-${SOFTWARE}/"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"

  rm $3/lib/libz*.dylib
}

build_main () {

  if [[ -d "$2/${SOFTWARE}" && "${ACTION}" == "skip" ]]
  then
      return 0
  elif [[ -d "$2/${SOFTWARE}" && -z "${ACTION}" ]]
  then
      echo "${SOFTWARE} build directory already exists but no action set. Exiting script"
      exit 0
  fi


  if [[ ! -d "$2/${SOFTWARE}" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  make_compile $@

}

build_main $@
