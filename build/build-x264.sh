#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

SOFTWARE=x264

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

curl -o x264-master.tar.gz -O -L https://github.com/mirror/x264/archive/master.tar.gz
  checkStatus $? "download of x264 failed"

# TODO: checksum validation (if available)

# unpack
  tar -zxf "x264-master.tar.gz"
  checkStatus $? "unpack x264 failed"
  cd "x264-master/"
  checkStatus $? "change directory failed"


}

configure_build () {

  cd "$2/${SOFTWARE}/x264-master/"
  checkStatus $? "change directory failed"

  # prepare build
  ./configure --prefix="$3" --enable-static
  checkStatus $? "configuration of ${SOFTWARE} failed"

}

make_clean() {

  cd "$2/${SOFTWARE}/x264-master/"
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"

}

make_compile () {

  cd "$2/${SOFTWARE}/x264-master/"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"

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
