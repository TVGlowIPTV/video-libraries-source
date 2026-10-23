# How the Android audio decoding library was built

`build.sh` in this folder is the script that built it, on Ubuntu 26.04 (x86_64,
under WSL 2). It fetches and checks every input:

- androidx/media tag 1.11.0 (`2bc207851df311340767e913931ca7b28cab1794`),
  changed by `media-tvglow.patch`;
- FFmpeg n7.1 (`b08d7969c550a804a59511c7b83f2dd8cc0499b8`), unchanged;
- Android NDK 28.2.13676358, CMake 3.22.1, Android platform 36 and build-tools
  36.0.0, installed by the Android command-line tools 15859902;
- Temurin JDK 17.0.19+10 and Gradle 9.1.0.

Run it with an absolute Linux path for the build directory:

```sh
bash build.sh /absolute/linux/build-directory
```

It needs git, make, clang, nasm, python3, curl and unzip on the host, and the
Android SDK licences accepted in `<build-directory>/sdk/licenses`.

## Our changes (`media-tvglow.patch`)

- `build_ffmpeg.sh`: FFmpeg is configured with `--disable-gpl
  --disable-version3 --disable-nonfree`, the AC-3, DTS and MLP parsers are
  enabled, and the 32-bit x86 build is removed.
- `decoder_ffmpeg/build.gradle.kts`: the NDK version is pinned and the native
  build is limited to arm64-v8a, armeabi-v7a and x86_64.
- `gradle-wrapper.properties`: the Gradle download is checked against its
  published SHA-256.

## Configuration

Media3's FFmpeg options (`--disable-everything`, static libraries, no
programs, no avformat, avfilter or swscale) plus the decoders `ac3`, `eac3`,
`dca`, `truehd` and `mlp` and the parsers `ac3`, `dca` and `mlp`. FFmpeg's
`config.h` reports `FFMPEG_LICENSE "LGPL version 2.1 or later"`.
