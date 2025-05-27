#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = output directory
# $5 = CPUs
# $6 = FFmpeg version

# load functions
. $1/functions.sh

SOFTWARE=ffmpeg-topaz
SOFT_PATH=${SOFTWARE}/FFmpeg-topaz-v${6}
SOFT_REDIST_PATH=${SOFTWARE}/ffmpeg-redist-${6}

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
  curl -Lo topaz-ffmpeg.zip  https://github.com/TopazLabs/FFmpeg/archive/refs/tags/topaz-v${6}.zip
  checkStatus $? "download of ${SOFTWARE} failed"

  # unpack ffmpeg
  unzip topaz-ffmpeg.zip
  checkStatus $? "$3 Source extract failed"
  
  cd ../${SOFT_PATH} 
  checkStatus $? "$3 Source directory failed"


  cd ..
  curl -Lo topaz-redist_ffmpeg.txz https://github.com/TopazLabs/FFmpeg/releases/download/topaz-v${6}/topaz-ffmpeg-redist-mac-${6}.txz
  checkStatus $? "download of ${SOFTWARE} librariesfailed"

  tar -xJf topaz-redist_ffmpeg.txz
  checkStatus $? "$3 Redist extract failed"

  cd ../${SOFT_REDIST_PATH} 
  checkStatus $? "$3 Source directory failed"


}

configure_build () {

  cd "$2/${SOFT_PATH}/"
  checkStatus $? "change directory failed"

  # prepare build
  FF_FLAGS="-L${3}/lib -I${3}/include"
  TOPAZ_FLAGS="-L${2}/${SOFT_REDIST_PATH}/lib -I${2}/${SOFT_REDIST_PATH}/include/videoai"
  export LDFLAGS="${FF_FLAGS} ${TOPAZ_FLAGS}"
  export CFLAGS="${FF_FLAGS} ${TOPAZ_FLAGS}"

  FFMPEG_EXTRAS=''
  
  if [[ "${ENABLE_FFPLAY}" == "TRUE" ]]
  then
       FFMPEG_EXTRAS="${FFMPEG_EXTRAS} --enable-sdl2"
  else
	   FFMPEG_EXTRAS="${FFMPEG_EXTRAS} --disable-sdl2 --disable-ffplay"
  fi

  if [[ "${ENABLE_AVISYNTHPLUS}" == "TRUE" ]]
  then
       FFMPEG_EXTRAS="${FFMPEG_EXTRAS} --enable-avisynth"
  fi

  TOPAZ_BREAKS='--enable-libopenh264'

  # --pkg-config-flags="--static" is required to respect the Libs.private flags of the *.pc files
  ./configure --prefix="$4" --enable-gpl --pkg-config-flags="--static"   --pkg-config=$3/bin/pkg-config \
      --enable-libaom --enable-libx264 --enable-libx265 --enable-libvpx \
      --enable-libmp3lame --enable-libopus --enable-neon --enable-runtime-cpudetect \
      --enable-audiotoolbox --enable-videotoolbox --enable-libvorbis --enable-libsvtav1 \
      --enable-libsrt --enable-libwebp --enable-libbluray \
      --enable-libass  --enable-opencl ${FFMPEG_EXTRAS} --enable-tvai --enable-nonfree --enable-libfdk-aac 
#      --enable-libass --enable-lto --enable-libopenh264 --enable-opencl ${FFMPEG_EXTRAS}

  checkStatus $? "configuration of ${SOFTWARE} failed"

}

make_clean() {

  cd "$2/${SOFT_PATH}/"
  checkStatus $? "change directory failed"
  make clean
  checkStatus $? "make clean for $SOFTWARE failed"


}

make_compile () {

  cd "$2/${SOFT_PATH}/"
  checkStatus $? "change directory failed"

  # build
  make -j $5
  checkStatus $? "build of ${SOFTWARE} failed"

  # install
  make install
  checkStatus $? "installation of ${SOFTWARE} failed"
  cp -r ${2}/${SOFT_REDIST_PATH}/Frameworks $4 
  cp -r ${2}/${SOFT_REDIST_PATH}/bin $4 

}

build_main () {


  # ffmpeg we always want to rebuild

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
