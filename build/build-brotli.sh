#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = vorbis version - unused get heads from git

# load functions
. $1/functions.sh

SOFTWARE=brotli

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
  git clone https://github.com/google/brotli.git 
  checkStatus $? "download of ${SOFTWARE} failed"

}

configure_build () {

  cd "$2/${SOFTWARE}/build-${SOFTWARE}/"
  checkStatus $? "change directory failed"
  
  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DINSTALL_PKGCONFIG_DIR=$3/lib/pkgconfig -DCMAKE_BUILD_TYPE=Release ../${SOFTWARE}
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

  rm $3/lib/libbrotli*.dylib
  ln -s $3/lib/libbrotlidec-static.a $3/lib/libbrotlidec.a
  ln -s $3/lib/libbrotlicommon-static.a $3/lib/libbrotlicommon.a
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
