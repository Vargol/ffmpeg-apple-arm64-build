#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = x265 version

set -x
# load functions
. $1/functions.sh


make_directories() {

# start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir "x265"
  checkStatus $? "create directory failed"
  cd "x265/"
  checkStatus $? "change directory failed"

}


download_code() {
  cd "$2/x265"
  checkStatus $? "change directory failed"

  # download source
  #curl -O -L https://github.com/videolan/x265/archive/$5.tar.gz
  git clone https://github.com/videolan/x265.git
  checkStatus $? "download of x265 failed"

  # TODO: checksum validation (if available)

  # unpack
  #tar -zxf "$5.tar.gz"
  #checkStatus $? "unpack x265 failed"

}

configure_build () {

  cd "$2/x265/x265"
  checkStatus $? "change directory failed"


  #patch for arm64 / neon recognition
  patch -p1 < $1/apple_arm64_x265.patch


  # prepare build

  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_SHARED=NO -DHIGH_BIT_DEPTH=ON -DMAIN12=ON source
  #cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_SHARED=NO source
  checkStatus $? "configuration of x265 failed"

}

make_clean() {

  cd "$2/x265/x265"
  checkStatus $? "change directory failed"

  make clean
  checkStatus $? "make clean of x265 failed"
  

}

make_compile () {

  cd "$2/x265/x265"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of x265 failed"

  # install
  make install
  checkStatus $? "installation of x265 failed"

  # post-installation
  # modify pkg-config file for usage with ffmpeg (it seems that the flag for threads is missing)
  sed -i.original -e 's/lx265/lx265 -lpthread/g' $3/lib/pkgconfig/x265.pc
 
}


build_main () {

  if [[ -d "$2/x265" && "${ACTION}" == "skip" ]]
  then
      return 0
  elif [[ -d "$2/x265" && -z "${ACTION}" ]]
  then
      echo "x265 build directory already exists but no action set. Exiting script"
      exit 0
  fi


  if [[ ! -d "$2/x265" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  make_compile $@

}


build_main $@
