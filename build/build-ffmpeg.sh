#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = output directory
# $5 = CPUs
# $6 = FFmpeg version

# load functions
. $1/functions.sh

# start in working directory
cd $2
checkStatus $? "change directory failed"
mkdir "ffmpeg"
checkStatus $? "create directory failed"
cd "ffmpeg/"
checkStatus $? "change directory failed"

# download ffmpeg source
curl -O https://ffmpeg.org/releases/ffmpeg-$6.tar.bz2

# TODO: checksum validation

# unpack ffmpeg
bunzip2 ffmpeg-$6.tar.bz2
tar -xf ffmpeg-$6.tar
cd "ffmpeg-$6/"
checkStatus $? "change directory failed"

# prepare build

FF_FLAGS="-L${3}/lib -I${3}/include"
export LDFLAGS="$FF_FLAGS"
export CFLAGS="$FF_FLAGS"
# --pkg-config-flags="--static" is required to respect the Libs.private flags of the *.pc files
./configure --prefix="$4" --enable-gpl --pkg-config-flags="--static"   --pkg-config=$3/bin/pkg-config \
    --enable-libaom --enable-libopenh264 --enable-libx264 --enable-libx265 --enable-libvpx \
    --enable-libmp3lame --enable-libopus --enable-neon --enable-runtime-cpudetect \
    --enable-audiotoolbox --enable-videotoolbox --enable-libvorbis --enable-libsvtav1
checkStatus $? "configuration of ffmpeg failed"

# start build
make -j $5
checkStatus $? "build of ffmpeg failed"

# install ffmpeg
make install
checkStatus $? "installation of ffmpeg failed"

