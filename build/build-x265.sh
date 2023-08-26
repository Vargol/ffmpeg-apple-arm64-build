#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = x265 version

 set -x
# load functions
. $1/functions.sh

if [[ "${BUILD_FROM_MAIN}" == "TRUE" ]]
then
BRANCH=""
PATCH="git apply $1/x265_arm64_threading.patch"
else
BRANCH="--branch stable"
PATCH="patch -p1 -i $1/apple_arm64_x265.patch"
fi

make_directories() {

# start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir "x265"
  checkStatus $? "create directory failed"
  cd "x265/"
  checkStatus $? "change directory failed"
  mkdir "8bit"
  checkStatus $? "create directory failed"
  mkdir "10bit"
  checkStatus $? "create directory failed"
  mkdir "12bit"
  checkStatus $? "create directory failed"

}


download_code() {
  cd "$2/x265"
  checkStatus $? "change directory failed"

  # download source
  #curl -O -L https://github.com/videolan/x265/archive/$5.tar.gz
  #git clone https://thub.com/videolan/x265.git

  # Build fails when using git shallow clone
  # https://bitbucket.org/multicoreware/x265_git/issues/572/pc-file-is-not-generated
  git clone https://bitbucket.org/multicoreware/x265_git.git ${BRANCH} 
  checkStatus $? "download of x265 failed"

  # TODO: checksum validation (if available)

  # unpack
  #tar -zxf "$5.tar.gz"
  #checkStatus $? "unpack x265 failed"

}

configure_build () {

  GIT_DIR=x265_git
  cd "$2/x265/$GIT_DIR"
  checkStatus $? "change directory failed"


  #patch for arm64 / neon recognition
  #patch -p1 < $1/apple_arm64_x265.patch
  ${PATCH}


  cd ../12bit

  # prepare build

FF
  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_SHARED=NO -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_CLI=OFF -DMAIN12=ON ../$GIT_DIR/source
  checkStatus $? "configuration of 12bit x265 failed"

  cd ../10bit

  # prepare build

  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_SHARED=NO -DHIGH_BIT_DEPTH=ON -DMAIN10=ON -DENABLE_HDR10_PLUS=ON -DEXPORT_C_API=OFF -DENABLE_CLI=OFF ../$GIT_DIR/source
  checkStatus $? "configuration of 10bit x265 failed"

  cd ../8bit

  # prepare build

  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_SHARED=NO -DEXTRA_LIB="x265_main10.a;x265_main12.a" -DEXTRA_LINK_FLAGS=-L. -DLINKED_10BIT=ON -DLINKED_12BIT=ON -DENABLE_CLI=OFF ../$GIT_DIR/source
  checkStatus $? "configuration of 8bit x265 failed"

}

make_clean() {

  cd "$2/x265/8bit"
  checkStatus $? "change directory failed"

  make clean
  checkStatus $? "make clean of x265 failed"

  cd "$2/x265/10bit"
  checkStatus $? "change directory failed"

  make clean
  checkStatus $? "make clean of x265 failed"

  cd "$2/x265/12bit"
  checkStatus $? "change directory failed"

  make clean
  checkStatus $? "make clean of x265 failed"


}

make_compile () {

  cd "$2/x265/12bit"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of x265 failed"

  cd "$2/x265/10bit"
  checkStatus $? "change directory failed"

  # build
  make -j $4
  checkStatus $? "build of x265 failed"

  cd "$2/x265/8bit"
  checkStatus $? "change directory failed"

  #soft symlink the libraies
  ln -sf ../10bit/libx265.a libx265_main10.a
  ln -sf ../12bit/libx265.a libx265_main12.a

  # build
  make -j $4
  checkStatus $? "build of x265 failed"

  #merge the libaries together
  mv libx265.a libx265_main.a
  libtool -static -o libx265.a libx265_main.a libx265_main10.a libx265_main12.a 2>/dev/null
  checkStatus $? "merge of x265 objects failed"

  # install
  make install
  checkStatus $? "installation of x265 failed"

 
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

