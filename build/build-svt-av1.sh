#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = version - unsed gets head from git

# load functions
. $1/functions.sh

SOFTWARE=svt-av1

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
  git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git 
  checkStatus $? "download of ${SOFTWARE} failed"
  cd SVT-AV1
  git checkout a49c786a81383d2dee7c8cdc8b5d46e5df3a7845
  checkStatus $? "git checkout a49c786a81383d2dee7c8cdc8b5d46e5df3a7845 failied"
  cd ..
}

configure_build () {

  cd $2/${SOFTWARE}/SVT-AV1/Build 
  checkStatus $? "change directory failed"

  # prepare build
  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DBUILD_SHARED_LIBS=OFF -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release ..
  checkStatus $? "configuration of ${SOFTWARE} failed"

}

make_clean() {

  cd $2/${SOFTWARE}/SVT-AV1/Build 
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"

}

make_compile () {

  cd $2/${SOFTWARE}/SVT-AV1/Build 
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
