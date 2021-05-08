#!/bin/sh
# $1 = build directory
# $2 = test directory
# $3 = working directory
# $4 = output directory

# load functions
. $1/functions.sh

# test aom av1
START_TIME=$(currentTimeInSeconds)
echoSection "run test aom av1 encoding"
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libaom-av1" -cpu-used 6 -row-mt 1 -an "$3/test-aom-av1.mp4" > "$3/test-aom-av1.log" 2>&1
checkStatus $? "test aom av1"
echoDurationInSections $START_TIME

# test openh264
START_TIME=$(currentTimeInSeconds)
echoSection "run test openh264 encoding"
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libopenh264" -an "$3/test-openh264.mp4" > "$3/test-openh264.log" 2>&1
checkStatus $? "test openh264"
echoDurationInSections $START_TIME

# test x264
START_TIME=$(currentTimeInSeconds)
echoSection "run test x264 encoding"
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libx264" -an "$3/test-x264.mp4" > "$3/test-x264.log" 2>&1
checkStatus $? "test x264"
echoDurationInSections $START_TIME

# test x265
START_TIME=$(currentTimeInSeconds)
echoSection "run test x265 encoding"
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libx265" -an "$3/test-x265.mp4" > "$3/test-x265.log" 2>&1
checkStatus $? "test x265"
echoDurationInSections $START_TIME

# test vp8
START_TIME=$(currentTimeInSeconds)
echoSection "run test vp8 encoding"
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libvpx" -an "$3/test-vp8.webm" > "$3/test-vp8.log" 2>&1
checkStatus $? "test vp8"
echoDurationInSections $START_TIME

# test vp9
START_TIME=$(currentTimeInSeconds)
echoSection "run test vp9 encoding"
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libvpx-vp9" -an "$3/test-vp9.webm" > "$3/test-vp9.log" 2>&1
checkStatus $? "test vp9"
echoDurationInSections $START_TIME

# test lame mp3
START_TIME=$(currentTimeInSeconds)
echoSection "run test lame mp3 encoding"
$4/bin/ffmpeg -i "$2/test.mp4" -c:a "libmp3lame" -vn "$3/test-lame.mp3" > "$3/test-lame.log" 2>&1
checkStatus $? "test lame mp3"
echoDurationInSections $START_TIME

# test opus
START_TIME=$(currentTimeInSeconds)
echoSection "run test opus encoding"
$4/bin/ffmpeg -i "$2/test.mp4" -c:a "libopus" -vn "$3/test-opus.opus" > "$3/test-opus.log" 2>&1
checkStatus $? "test opus"
echoDurationInSections $START_TIME

# testi vorbis 
START_TIME=$(currentTimeInSeconds)
echoSection "run test vorbis encoding"
$4/bin/ffmpeg -i "$2/test.mp4" -c:a "libvorbis" -vn "$3/test-vorbis.ogg" > "$3/test-vorbis.log" 2>&1
checkStatus $? "test vorbis"
echoDurationInSections $START_TIME
