# TVGlow video libraries: source code

TVGlow uses the mpv and FFmpeg libraries to play video. They are free
software, used under the GNU Lesser General Public License. This repository
holds the source code of those libraries, and of the libraries built into
them, as used in TVGlow, including our changes and the scripts used to build
them.

It does not contain TVGlow itself. No part of the TVGlow application is here.

## What is here

| TVGlow | Libraries | Sources |
| --- | --- | --- |
| Windows | mpv 0.39.0 and FFmpeg 7.1, built by us as one library, `libmpv-2.dll` (SHA-256 `66af658d…1c0ef0c`) | [`windows/libmpv-66af658d`](windows/libmpv-66af658d), release [`windows-libmpv-66af658d`](https://github.com/TVGlowIPTV/video-libraries-source/releases/tag/windows-libmpv-66af658d) |
| Windows | mpv 0.39.0 and FFmpeg 7.1 with zvbi 0.2.46 (teletext), built by us as one library, `libmpv-2.dll` (SHA-256 `1c553bca…9702fde6`) | [`windows/libmpv-1c553bca`](windows/libmpv-1c553bca), release [`windows-libmpv-1c553bca`](https://github.com/TVGlowIPTV/video-libraries-source/releases/tag/windows-libmpv-1c553bca) |
| Windows | mpv 0.39.0 and FFmpeg 7.1 with zvbi 0.2.46 (teletext) and the TrueHD/MLP decoders, built by us as one library, `libmpv-2.dll` (SHA-256 `72a09be1…ab6343b0e`) | [`windows/libmpv-72a09be1`](windows/libmpv-72a09be1), release [`windows-libmpv-72a09be1`](https://github.com/TVGlowIPTV/video-libraries-source/releases/tag/windows-libmpv-72a09be1) |
| Android and Android TV | FFmpeg 7.1 audio decoders in Media3's FFmpeg decoder module 1.11.0, built by us as `libffmpegJNI.so` (in `media3-decoder-ffmpeg-1.11.0.aar`, SHA-256 `7a940a39…85286bb0`) | [`android/media3-ffmpeg-7a940a39`](android/media3-ffmpeg-7a940a39), release [`android-media3-ffmpeg-7a940a39`](https://github.com/TVGlowIPTV/video-libraries-source/releases/tag/android-media3-ffmpeg-7a940a39) |
| iPhone and iPad | mpv 0.36.0 and FFmpeg 6.0, as built by the media-kit project (release v0.6.0), unchanged by us | [`ios/libmpv-darwin-build-v0.6.0`](ios/libmpv-darwin-build-v0.6.0), release [`ios-libmpv-0.6.0`](https://github.com/TVGlowIPTV/video-libraries-source/releases/tag/ios-libmpv-0.6.0) |

TVGlow for Android and Android TV includes only FFmpeg's audio decoders,
built into Media3's FFmpeg decoder module; it does not include mpv.

Each folder has a `SOURCES.md` that lists every library with its version, the
address it comes from and a checksum. The source archives themselves are
attached to the releases named above, because they are too large to keep in
the repository's history.

The Licences page inside TVGlow shows which libraries a given version of the
app uses. When the libraries change, a new folder and release are added here
and the earlier ones stay.

## Windows

[`windows/libmpv-66af658d`](windows/libmpv-66af658d) has our build script
(`build.sh`), our changes to the build recipe (`recipe.patch`), our patches to
FFmpeg and libplacebo, the checksum of the library we ship (`SHA256SUMS`), how
it was built ([`BUILD-NOTES.md`](windows/libmpv-66af658d/BUILD-NOTES.md)) and
how to use TVGlow with a library you built yourself
([`REPLACING.md`](windows/libmpv-66af658d/REPLACING.md)).

## Android and Android TV

[`android/media3-ffmpeg-7a940a39`](android/media3-ffmpeg-7a940a39) has our
build script (`build.sh`), our changes to the Media3 module
(`media-tvglow.patch`), the checksum of the library we ship (`SHA256SUMS`),
how it was built ([`BUILD-NOTES.md`](android/media3-ffmpeg-7a940a39/BUILD-NOTES.md))
and how to use TVGlow with a library you built yourself
([`REPLACING.md`](android/media3-ffmpeg-7a940a39/REPLACING.md)).

## iPhone and iPad

[`ios/libmpv-darwin-build-v0.6.0`](ios/libmpv-darwin-build-v0.6.0) names the
media-kit build these libraries come from, lists the source archives that
build uses, and has its patches. We do not change these libraries.

## Licences

[`LICENSES`](LICENSES) has the texts of the GNU Lesser General Public License
(versions 3 and 2.1), the GNU General Public License version 3, to which
version 3 of the Lesser licence refers, and the Apache License 2.0, and the
copyright notices of the libraries for each platform
(`NOTICES-windows.txt`, `NOTICES-ios.txt`, `NOTICES-android.txt`). Each library's own licence file is
also inside its source archive.

Our patches to FFmpeg, libplacebo and zvbi are under the licence of the
library they change.

## Contact

support@tvglow.app
