# FFmpeg
This script is made to compile FFmpeg with common codecs on Mac OSX running on Apple Silicon.
The script was orginally taken from https://gitlab.com/martinr92/ffmpeg and has been modifed to build
the libraries with ARM64/NEON code were applicable.

The version of x265 also includes the Apple provided patch used by Handbreak, 
https://github.com/HandBrake/HandBrake/blob/master/contrib/x265/A01-darwin-neon-support-for-arm64.patch
forward ported to apply to newer versions of x265 this is not in the main line code but runs significantly faster.
This version also correctly reports that ARM64 is 64 bit not 32 bit :-)

## Result
This repository builds FFmpeg and FFprobe for Mac OSX using
- build tools
    - [cmake](https://cmake.org/)
    - [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/)
- video codecs
    - [SVT-AV1](https://github.com/AOMediaCodec/SVT-AV1) for AV1 de-/encoding
    - [aom](https://aomedia.org/) for AV1 de-/encoding
    - [openh264](https://www.openh264.org/) for H.264 de-/encoding
    - [x264](http://www.videolan.org/developers/x264.html) for H.264 encoding
    - [x265](http://x265.org/) for H.265/HEVC encoding
    - [vpx](https://www.webmproject.org/) for VP8/VP9 de-/encoding
- audio codecs
    - [LAME](http://lame.sourceforge.net/) for MP3 encoding
    - [opus](https://opus-codec.org/) for Opus de-/encoding
    - [vorbis](https://www.xiph.org) for Vorbis de-/encoding
    - [fdk-aac](https://sourceforge.net/projects/opencore-amr/files/fdk-aac/) for FDK-AAC de-/encoding
To get a full list of all formats and codecs that are supported just execute
```
./ffmpeg -formats
./ffmpeg -codecs
```

## Requirements
There are just a few dependencies to other tools. Most of the software is compiled or downloaded during script execution. Also most of the tools should be already available on the system by default.

### Required
- c and c++ compiler like AppleClang (included in Xcode) or gcc
- curl / git for downloading files
- make

### Optional
- sysctl (on Mac OSX) for multicore compilation

## Execution
To run this script simply execute the build.sh script.
```
./build.sh
This now has an optional parameter, either skip or clean.
This is used for re-runs of the script and it will either skip previously built codecs
or recompile existing codecs. Note it using this options ffmpeg is always recomiled afterwards.
e.g. is you want to refresh just the aom codec, them delete the aom directory from the build folder, and run build.sh skip
and it will skip all the exist folders and download and build libaom.

```

## Folder Structure
All files that are downloaded and generated through this script are placed in the current working directory. The recommendation is to use an empty folder for this.
```
mkdir ffmpeg-compile
cd ffmpeg-compile
```

Now execute the script using:
```
../path/to/repository/build.sh
```

After the execution a new folder called "out" exists. It contains the compiled FFmpeg binary (in the bin sub-folder).
The ffmpeg-success.zip contains also all binary files for FFmpeg.

## Build failed?
Check the detailed logfiles in the working directory. Each build step has its own file starting with "build-*".

If the build of ffmpeg failes during the configuration phase (e.g. because it doesn't find one codec) check also the log file in ffmpeg/ffmpeg-*/ffbuild/config.log.
