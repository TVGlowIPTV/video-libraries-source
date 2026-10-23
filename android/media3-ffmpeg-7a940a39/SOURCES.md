# Sources of the Android audio decoding library

The Android versions of TVGlow carry one library built from FFmpeg:
`libffmpegJNI.so`, one copy per processor type (arm64-v8a, armeabi-v7a,
x86_64). It is Media3's FFmpeg decoder module with FFmpeg's libavcodec,
libavutil and libswresample linked into it. The module is shipped in
`media3-decoder-ffmpeg-1.11.0.aar`, SHA-256
`7a940a39249e0e5c4f779843f79bbb92ae1ee0cad8f965c953e7a26385286bb0`
(`SHA256SUMS`).

The archives are attached to the release `android-media3-ffmpeg-7a940a39` and
were made with `git archive` at the exact commits that were built.

| Component | Version | Commit | Upstream | Archive | SHA-256 | Note |
| --- | --- | --- | --- | --- | --- | --- |
| FFmpeg | n7.1 | `b08d7969c550a804a59511c7b83f2dd8cc0499b8` | https://github.com/FFmpeg/FFmpeg.git | `ffmpeg-b08d7969c550.tar.gz` | `69d947b20f67db1ce4770d097c286e6d78b5a71236d8fff1f2ca02d5939b9e61` | Built without changes. The same commit is also attached to release `windows-libmpv-66af658d`. |
| Media3 FFmpeg decoder module (androidx/media) | 1.11.0 | `2bc207851df311340767e913931ca7b28cab1794` | https://github.com/androidx/media.git | `androidx-media-decoder_ffmpeg-2bc207851df3.tar.gz` (`libraries/decoder_ffmpeg` and `LICENSE`) | `555a822b9b2214bebc45cb5d76f67ba5d47cf2bcd8fcfe7c50d8be98b29e82cf` | Built with changes: `androidx-media-2bc207851df3-local-changes.patch` (also `media-tvglow.patch` in this folder). Apache License 2.0. |

The module builds against Media3 1.11.0's other libraries, which are published
on Google's Maven repository (`androidx.media3`, version 1.11.0).

The NDK's C++ runtime (LLVM libc++) is linked in as supplied by Android NDK
28.2.13676358.
