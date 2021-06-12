#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = vorbis version - unused get heads from git

# load functions
. $1/functions.sh

SOFTWARE=harfbuzz

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
  git clone https://github.com/harfbuzz/harfbuzz.git 
  checkStatus $? "download of ${SOFTWARE} failed"

}

configure_build () {

  cd "$2/${SOFTWARE}/build-${SOFTWARE}/"
  checkStatus $? "change directory failed"

  # prepare build
  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DBUILD_SHARED_LIBS=OFF ../${SOFTWARE}
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

echo "prefix=$3
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include
Name: harfbuzz
Description: HarfBuzz text shaping library
Version: 2.8.1

Libs: -L\${libdir} -lharfbuzz
Libs.private: -lm     -framework ApplicationServices
Cflags: -I\${includedir}/harfbuzz" > "$3/lib/pkgconfig/$SOFTWARE.pc" 


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
