#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = pkg-config version

# load functions
. $1/functions.sh

set -x

make_directories() {
  
  # start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir "pkg-config"
  checkStatus $? "create directory failed"
  cd "pkg-config/"
  checkStatus $? "change directory failed"

}

download_code() {

  cd "$2/pkg-config" 
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

}

configure_build() {

  cd "$2/pkg-config/pkg-config-$4" 
  checkStatus $? "change directory failed"

  # prepare build
  ./configure --prefix="$3" --with-pc-path="$3/lib/pkgconfig" --with-internal-glib
  checkStatus $? "configuration of pkg-config failed"

}


make_clean() {

  cd "$2/pkg-config/pkg-config-$4" 
  checkStatus $? "change directory failed"

  make clean
  checkStatus $? "make clean of pkg-config failed"

}

make_compile() {

  cd "$2/pkg-config/pkg-config-$4" 
  checkStatus $? "change directory failed"

  # build
  make
  checkStatus $? "build of pkg-config failed"

  # install
  make install
  checkStatus $? "installation of pkg-config failed"

}



build_main () {


  if [[ -d "$2/pkg-config" && "${ACTION}" == "skip" ]]
  then
      return 0
  elif [[ -d "$2/pkg-config" && -z "${ACTION}" ]]
  then
      echo "pkg-config build directory already exists but no action set. Exiting script"
      exit 0
  fi


  if [[ ! -d "$2/pkg-config" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  make_compile $@
}


build_main $@
