#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = vorbis version - unused get heads from git

# load functions
. $1/functions.sh

SOFTWARE=libbluray-1.3.4
GIT_REPO=yyy

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
  curl -Lo libbluray-1.3.4.tar.bz2 https://download.videolan.org/pub/videolan/libbluray/1.3.4/libbluray-1.3.4.tar.bz2
  checkStatus $? "download of ${SOFTWARE} failed"
  tar -xf libbluray-1.3.4.tar.bz2 

}

configure_build () {

  cd "$2/${SOFTWARE}/${SOFTWARE}/"
  checkStatus $? "change directory failed"
  git apply $1/libblu_dec_init.patch
  checkStatus $? "git apply patch failed"


  cd "$2/${SOFTWARE}/build-${SOFTWARE}/"
  checkStatus $? "change directory failed"

  # prepare build
  LIBXML2_CFLAGS='-I /usr/include/libxml2', LIBXML2_LIBS='-lxml2' ../${SOFTWARE}/configure --prefix="$3" --enable-shared=no --disable-bdjava-jar
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
  sed -i '' "s/libxml-2.0 >= 2.6//" $3/lib/pkgconfig/libbluray.pc
  sed -i '' "s/lbluray/lbluray -lxml2/" $3/lib/pkgconfig/libbluray.pc
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
