#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = cmake major version
# $6 = cmake full version

# load functions
. $1/functions.sh
set -x

make_directories() {

# start in working directory
  cd "$2"
  checkStatus $? "change directory failed"

  mkdir "cmake"
  checkStatus $? "create directory failed"

  cd "cmake/"
  checkStatus $? "change directory failed"
 
}

download_code() {

  cd $2/cmake

  # download source
  # curl -O https://cmake.org/files/v$5/cmake-$6.tar.gz
  curl -LO https://github.com/Kitware/CMake/releases/download/v${6}/cmake-${6}.tar.gz

  checkStatus $? "download of cmake failed"

  # TODO: checksum validation (if available)

  # unpack
  tar -zxf "cmake-$6.tar.gz"
  checkStatus $? "unpack of cmake failed"

}


configure_build() {

  cd "$2/cmake/cmake-$6/"
  checkStatus $? "change directory failed"

  # prepare build
  ./configure --prefix="$3" --parallel="$4"
  checkStatus $? "configuration of cmake failed"

}

make_clean() {

  cd "$2/cmake/cmake-$6/"
  make clean
  checkStatus $? "make clean of cmake failed"

}

make_compile() {

  cd "$2/cmake/cmake-$6/"
  # build
  make -j $4
  checkStatus $? "build of cmake failed"

  # install
  make install
  checkStatus $? "installation of cmake failed"

}


build_main () {

  if [[ -d "$2/cmake" && "${ACTION}" == "skip" ]]
  then
      return 0
  elif [[ -d "$2/cmake" && -z "${ACTION}" ]]
  then
      echo "camke build directory already exists but no action set. Exiting script"
      exit 0 
  fi
  
    
  if [[ ! -d "$2/cmake" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi
  
  make_clean $@
  make_compile $@

}


build_main $@
