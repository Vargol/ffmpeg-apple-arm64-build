#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = aom version

# load functions
. $1/functions.sh


SOFTWARE=aom

make_directories() {

  # start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir ${SOFTWARE}
  checkStatus $? "create directory failed"
  cd ${SOFTWARE}
  checkStatus $? "change directory failed"

}

download_code () {

  cd "$2/${SOFTWARE}"
  checkStatus $? "change directory failed"
  # download source
  git clone https://aomedia.googlesource.com/aom

  checkStatus $? "download of ${SOFTWARE} failed"

}

configure_build () {

  cd "$2/${SOFTWARE}/${SOFTWARE}/"
  checkStatus $? "change directory failed"

  # prepare build
  mkdir ../aom_build
  checkStatus $? "create aom build directory failed"
  cd ../aom_build

  checkStatus $? "change directory to aom build failed"
  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_NEON=ON -DHAVE_NEON=1 -DENABLE_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-O3" -DCMAKE_C_FLAGS="-O3" ../aom/
  checkStatus $? "configuration of aom failed"

}

make_clean() {

  cd "$2/${SOFTWARE}/aom_build"
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"

}

make_compile () {

  cd "$2/${SOFTWARE}/aom_build/"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"

}

build_main () {


set -x

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
