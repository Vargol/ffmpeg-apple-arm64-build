#!/bin/sh

# Option feature set to FALSE if not required and TRUE if required
ENABLE_FFPLAY=FALSE
ENABLE_TOPAZ=FALSE
ENABLE_AVISYNTHPLUS=FALSE
BUILD_FROM_MAIN=TRUE

# set true for dependant features, export those needed in ffmpeg build script
 
if [[ "${ENABLE_TOPAZ}" == "TRUE" ]]
then
    export ENABLE_TOPAZ=TRUE
    echo You have enabled Topaz Video AI support.
    echo This execuatable can not be re-distributed under the terms of the GPL
    echo and hence is for your private use only.
    echo Using the Topaz Video AI filters requires an activate Topaz Video AI licence.
    echo and install of the Application with the models you wish to use.
    echo To use the Topaz Video AI filters you must set the environment variable TVAI_MODEL_DIR 
    echo and log into Topaz using the login commanda
    echo 
    echo export TVAI_MODEL_DIR="/Applications/Topaz Video AI.app/Contents/Resources/models"
    echo export TVAI_MODEL_DATA_DIR="/Applications/Topaz Video AI.app/Contents/Resources/models"
    echo 
    echo If you have logged out of your Topaz account you can log in using
    echo out/bin/login topaz_account_email_address topaz_account_password 
    echo 

fi

if [[ "${ENABLE_FFPLAY}" == "TRUE" ]]
then
    export ENABLE_FFPLAY=TRUE
fi

if [[ "${ENABLE_AVISYNTHPLUS}" == "TRUE" ]]
then
    export ENABLE_AVISYNTHPLUS=TRUE
    echo "Enabling AviSynthPlus will meaan this binary is not longer staticly built."
    echo "To use AviSynthPlus you will need to run from the tool/lib directory or a directory with a link to the tool/lib/libavisynth.dylib file"
    echo 
fi

if [[ "${BUILD_FROM_MAIN}" == "TRUE" ]]
then
    export BUILD_FROM_MAIN=TRUE
    echo "Enabling Build from main."
    echo "This will build ffmpeg and x265 from their respective source repositories."
    echo "This will this will get you the latest and greatest, but increases the chances the build will fail"
    echo 
fi

# get rid of macports - libiconv
export PATH=`echo $PATH | sed 's/:/\n/g' | grep -v '/opt/local' | xargs | tr ' ' ':'`

which sed

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

export PKG_CONFIG_PATH=${TOOL_DIR}/lib/pkgconfig


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
echoSection "compile fdk-aac"
$SCRIPT_DIR/build-fdk-aac.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "2.0.2" > "$WORKING_DIR/build-fdk-aac.log" 2>&1
checkStatus $? "build fdk-aac"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile x265"
$SCRIPT_DIR/build-x265.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "3.6" > "$WORKING_DIR/build-x265.log" 2>&1
checkStatus $? "build x265"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile svt-av1"
$SCRIPT_DIR/build-svt-av1.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "v2.3.0" > "$WORKING_DIR/build-svt-av1.log" 2>&1
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
#$SCRIPT_DIR/build-openh264.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "2.1.1" > "$WORKING_DIR/build-openh264.log" 2>&1
$SCRIPT_DIR/build-openh264.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "2.3.0" > "$WORKING_DIR/build-openh264.log" 2>&1
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
$SCRIPT_DIR/build-opus.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "v1.5.1" > "$WORKING_DIR/build-opus.log" 2>&1
checkStatus $? "build opus"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile fontconfig"
$SCRIPT_DIR/build-fontconfig.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxx" > "$WORKING_DIR/build-fontconfig.log" 2>&1
checkStatus $? "build fontconfig"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile libbluray"
$SCRIPT_DIR/build-libbluray.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxx" > "$WORKING_DIR/build-libbluray.log" 2>&1
checkStatus $? "build libbluray"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile libwebp"
$SCRIPT_DIR/build-libwebp.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxx" > "$WORKING_DIR/build-libwebp.log" 2>&1
checkStatus $? "build libwebp"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile openssl"
$SCRIPT_DIR/build-openssl.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxx" > "$WORKING_DIR/build-openssl.log" 2>&1
checkStatus $? "build openssl"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile libsrt"
$SCRIPT_DIR/build-libsrt.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxx" > "$WORKING_DIR/build-libsrt.log" 2>&1
checkStatus $? "build srt"
echoDurationInSections $START_TIME


if [[ "${ENABLE_FFPLAY}" == "TRUE" ]]
then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile sdl2"
    $SCRIPT_DIR/build-sdl2.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "xxxx" > "$WORKING_DIR/build-sdl2.log" 2>&1
    checkStatus $? "build sdl2"
    echoDurationInSections $START_TIME
fi

if [[ "${ENABLE_AVISYNTHPLUS}" == "TRUE" ]]
then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile AviSythnPlus"
    $SCRIPT_DIR/build-avisynth.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "v3.7.2" > "$WORKING_DIR/build-avisynth.log" 2>&1
    checkStatus $? "build AviSythnPlus"
    echoDurationInSections $START_TIME
fi


START_TIME=$(currentTimeInSeconds)
if [[ "${ENABLE_TOPAZ}" == "TRUE" ]]
then
echoSection "compile ffmpeg with topaz"
$SCRIPT_DIR/build-ffmpeg-topaz.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$OUT_DIR" "$CPUS" "7.0.0.3" > "$WORKING_DIR/build-ffmpeg-topaz.log" 2>&1
else
echoSection "compile ffmpeg"
$SCRIPT_DIR/build-ffmpeg.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$OUT_DIR" "$CPUS" "7.0.2" > "$WORKING_DIR/build-ffmpeg.log" 2>&1
fi

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
