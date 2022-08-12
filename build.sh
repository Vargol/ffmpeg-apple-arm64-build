#!/bin/sh
set -x


# Option feature set to FALSE if not rewuired and TRUE if required
ENABLE_FFPLAY=FALSE

# set true for dependant features, export those needed in ffmpeg build script
 
if [[ ${ENABLE_FFPLAY} == "TRUE" ]]
then
    export ENABLE_FFPLAY=TRUE
fi

# get rid of macports - libiconv
export PATH=`echo $PATH | sed 's/:/\n/g' | grep -v '/opt/local' | xargs | tr ' ' ':'`

ACTION=$1
if [[ -z "${ACTION}" ]]
then
   echo "No action set, all failures wil stop the script" 
elif [[  "${ACTION}" == "clean" ]]
then
   echo "Action set to clean, existing build folders will have make clean run" 
elif [[ "${ACTION}" == "skip" ]]
then
   echo "Action set to clean, existing build folders will be skipped" 
else
   echo "Action set to ${ACTION}, unknow option should be clean or skip" 
   exit 1
fi


export ACTION=$ACTION

# some folder names
BASE_DIR="$( cd "$( dirname "$0" )" > /dev/null 2>&1 && pwd )"
echo "base directory is ${BASE_DIR}"
SCRIPT_DIR="${BASE_DIR}/build"
echo "script directory is ${SCRIPT_DIR}"
TEST_DIR="${BASE_DIR}/test"
echo "test directory is ${TEST_DIR}"
WORKING_DIR="$( pwd )"
echo "working directory is ${WORKING_DIR}"
TOOL_DIR="$WORKING_DIR/tool"
echo "tool directory is ${TOOL_DIR}"
OUT_DIR="$WORKING_DIR/out"
echo "output directory is ${OUT_DIR}"

# load functions
. $SCRIPT_DIR/functions.sh

# prepare workspace
echoSection "prepare workspace"
mkdir "$TOOL_DIR"
checkStatusAndAction $? "unable to create tool directory"
PATH="$TOOL_DIR/bin:$PATH"
mkdir "$OUT_DIR"
checkStatusAndAction $? "unable to create output directory"

# detect CPU threads (nproc for linux, sysctl for osx)
CPUS=1
CPUS_NPROC="$(nproc 2> /dev/null)"
if [ $? -eq 0 ]
then
    CPUS=$CPUS_NPROC
else
    CPUS_SYSCTL="$(sysctl -n hw.ncpu 2> /dev/null)"
    if [ $? -eq 0 ]
    then
        CPUS=$CPUS_SYSCTL
    fi
fi

echo "use ${CPUS} cpu threads"
COMPILATION_START_TIME=$(currentTimeInSeconds)

#START_TIME=$(currentTimeInSeconds)
#echoSection "compile autoconf"
#$SCRIPT_DIR/build-autoconf.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "2.71" > "$WORKING_DIR/build-autoconf.log" 2>&1
#checkStatus $? "build autoconf"
#echoDurationInSections $START_TIME

# start build
#START_TIME=$(currentTimeInSeconds)
#echoSection "compile nasm"
#$SCRIPT_DIR/build-nasm.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "2.14.02" > "$WORKING_DIR/build-nasm.log" 2>&1
#checkStatus $? "build nasm"
#echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile cmake"
$SCRIPT_DIR/build-cmake.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "3.20" "3.20.2" > "$WORKING_DIR/build-cmake.log" 2>&1
checkStatus $? "build cmake"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile pkg-config"
$SCRIPT_DIR/build-pkg-config.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "0.29.2" > "$WORKING_DIR/build-pkg-config.log" 2>&1
checkStatus $? "build pkg-config"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile FriBidi"
$SCRIPT_DIR/build-fribidi.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "1.0.10" > "$WORKING_DIR/build-fribidi.log" 2>&1
checkStatus $? "build FriBidi"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile zlib"
$SCRIPT_DIR/build-zlib.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxxxx" > "$WORKING_DIR/build-zlib.log" 2>&1
checkStatus $? "build zlib"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile libpng"
$SCRIPT_DIR/build-libpng.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxxxxx" > "$WORKING_DIR/build-libpng.log" 2>&1
checkStatus $? "build libpng"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile brotli"
$SCRIPT_DIR/build-brotli.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxxxxx" > "$WORKING_DIR/build-brotli.log" 2>&1
checkStatus $? "build brotli"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile freetype"
$SCRIPT_DIR/build-freetype.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "VER-2-11-1" > "$WORKING_DIR/build-freetype.log" 2>&1
checkStatus $? "build freetype"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile harfbuzz"
$SCRIPT_DIR/build-harfbuzz.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxxx" > "$WORKING_DIR/build-harfbuzz.log" 2>&1
checkStatus $? "build harfbuzz"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile libass"
$SCRIPT_DIR/build-libass.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "0.15.1" > "$WORKING_DIR/build-libass.log" 2>&1
checkStatus $? "build libass"
echoDurationInSections $START_TIME


START_TIME=$(currentTimeInSeconds)
echoSection "compile x265"
$SCRIPT_DIR/build-x265.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "3.4" > "$WORKING_DIR/build-x265.log" 2>&1
checkStatus $? "build x265"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile svt-av1"
$SCRIPT_DIR/build-svt-av1.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxxx" > "$WORKING_DIR/build-svt-av1.log" 2>&1
checkStatus $? "build svt-av1"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile ogg"
$SCRIPT_DIR/build-ogg.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxxx" > "$WORKING_DIR/build-ogg.log" 2>&1
checkStatus $? "build ogg"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile vorbis"
$SCRIPT_DIR/build-vorbis.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxxx" > "$WORKING_DIR/build-vorbis.log" 2>&1
checkStatus $? "build vorbis"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile aom"
$SCRIPT_DIR/build-aom.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "2.0.0" > "$WORKING_DIR/build-aom.log" 2>&1
checkStatus $? "build aom"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile openh264"
$SCRIPT_DIR/build-openh264.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "2.1.1" > "$WORKING_DIR/build-openh264.log" 2>&1
checkStatus $? "build openh264"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile x264"
$SCRIPT_DIR/build-x264.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" > "$WORKING_DIR/build-x264.log" 2>&1
checkStatus $? "build x264"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile vpx"
$SCRIPT_DIR/build-vpx.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "1.9.0" > "$WORKING_DIR/build-vpx.log" 2>&1
checkStatus $? "build vpx"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile lame (mp3)"
$SCRIPT_DIR/build-lame.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "3.100" > "$WORKING_DIR/build-lame.log" 2>&1
checkStatus $? "build lame"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile opus"
$SCRIPT_DIR/build-opus.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "1.3.1" > "$WORKING_DIR/build-opus.log" 2>&1
checkStatus $? "build opus"
echoDurationInSections $START_TIME

set -x

if [[ "${ENABLE_FFPLAY}" = "TRUE" ]]
then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile sdl2"
    $SCRIPT_DIR/build-sdl2.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxxx" > "$WORKING_DIR/build-sdl2.log" 2>&1
    checkStatus $? "build sdl2"
    echoDurationInSections $START_TIME
fi

START_TIME=$(currentTimeInSeconds)
echoSection "compile ffmpeg"
$SCRIPT_DIR/build-ffmpeg.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$OUT_DIR" "$CPUS" "5.1" > "$WORKING_DIR/build-ffmpeg.log" 2>&1
checkStatus $? "build ffmpeg"
echoDurationInSections $START_TIME

echo "compilation finished successfully"
echoDurationInSections $COMPILATION_START_TIME

echoSection "bundle result"
cd "$OUT_DIR/bin/"
checkStatus $? "change directory"
zip -9 -r "$WORKING_DIR/ffmpeg-success.zip" *

echoSection "run tests"
$TEST_DIR/test.sh "$SCRIPT_DIR" "$TEST_DIR" "$WORKING_DIR" "$OUT_DIR" > "$WORKING_DIR/test.log" 2>&1
checkStatus $? "test"
echo "tests executed successfully"
