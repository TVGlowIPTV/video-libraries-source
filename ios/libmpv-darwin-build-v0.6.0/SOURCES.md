# Sources of the video libraries in TVGlow for iPhone and iPad

TVGlow for iPhone and iPad uses the video libraries as built by the media-kit
project: release `v0.6.0` of
[media-kit/libmpv-darwin-build](https://github.com/media-kit/libmpv-darwin-build),
flavor `default`, variant `video`. We do not build or change these libraries.
They are separate dynamic frameworks inside the app: Mpv, Avcodec, Avfilter,
Avformat, Avutil, Swresample, Swscale, Ass, Freetype, Fribidi, Harfbuzz,
Png16, Uchardet, Xml2, Dav1d, Mbedtls, Mbedcrypto and Mbedx509.

## The compiled libraries are referenced, not included

The compiled frameworks are not in this repository or its releases. The app's
build downloads media-kit's archive
`libmpv-xcframeworks_v0.6.0_ios-universal-video-default.tar.gz` from that
project's `v0.6.0` release and checks it against SHA-256
`a95bc18508af26136b8a408341c05b5585d644ec013f00ac07db09d2e28d36ae`.

How that archive ties to the sources below: media-kit's build scripts at
`v0.6.0` build it from the source archives named in their `downloads.lock`,
each identified there by address and SHA-256, with the patches in their
`patches/` folder. The table lists those archives for this flavor, with the
same checksums, and they are attached to the release
[`ios-libmpv-0.6.0`](https://github.com/TVGlowIPTV/video-libraries-source/releases/tag/ios-libmpv-0.6.0)
so that they stay available. The build scripts themselves are attached as
[libmpv-darwin-build-0.6.0.tar.gz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/libmpv-darwin-build-0.6.0.tar.gz) (SHA-256 `afade6a15e001700c6d92860bb33eba43020450001e7464595717ab9a222d28a`), and
their patches are also in the `patches/` folder here.

libpng is in the compiled libraries (FreeType is built with PNG support) but
is not named in `downloads.lock`. The compiled library reports version 1.6.40;
the archive listed is that release from the libpng project.

| Library | Version | Upstream archive | Copy | SHA-256 |
| --- | --- | --- | --- | --- |
| mpv | 0.36.0 | https://github.com/mpv-player/mpv/archive/refs/tags/v0.36.0.tar.gz | [mpv-0.36.0.tar.gz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/mpv-0.36.0.tar.gz) | `29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6` |
| FFmpeg | 6.0 | https://ffmpeg.org/releases/ffmpeg-6.0.tar.xz | [ffmpeg-6.0.tar.xz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/ffmpeg-6.0.tar.xz) | `57be87c22d9b49c112b6d24bc67d42508660e6b718b3db89c44e47e289137082` |
| libass | 0.17.1 | https://github.com/libass/libass/releases/download/0.17.1/libass-0.17.1.tar.xz | [libass-0.17.1.tar.xz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/libass-0.17.1.tar.xz) | `f0da0bbfba476c16ae3e1cfd862256d30915911f7abaa1b16ce62ee653192784` |
| FreeType | 2.13.2 | https://downloads.sourceforge.net/project/freetype/freetype2/2.13.2/freetype-2.13.2.tar.xz | [freetype-2.13.2.tar.xz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/freetype-2.13.2.tar.xz) | `12991c4e55c506dd7f9b765933e62fd2be2e06d421505d7950a132e4f1bb484d` |
| HarfBuzz | 8.1.1 | https://github.com/harfbuzz/harfbuzz/archive/8.1.1.tar.gz | [harfbuzz-8.1.1.tar.gz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/harfbuzz-8.1.1.tar.gz) | `b16e6bc0fc7e6a218583f40c7d201771f2e3072f85ef6e9217b36c1dc6b2aa25` |
| GNU FriBidi | 1.0.13 | https://github.com/fribidi/fribidi/releases/download/v1.0.13/fribidi-1.0.13.tar.xz | [fribidi-1.0.13.tar.xz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/fribidi-1.0.13.tar.xz) | `7fa16c80c81bd622f7b198d31356da139cc318a63fc7761217af4130903f54a2` |
| Mbed TLS | 3.4.1 | https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v3.4.1.tar.gz | [mbedtls-3.4.1.tar.gz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/mbedtls-3.4.1.tar.gz) | `a420fcf7103e54e775c383e3751729b8fb2dcd087f6165befd13f28315f754f5` |
| uchardet | 0.0.8 | https://www.freedesktop.org/software/uchardet/releases/uchardet-0.0.8.tar.xz | [uchardet-0.0.8.tar.xz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/uchardet-0.0.8.tar.xz) | `e97a60cfc00a1c147a674b097bb1422abd9fa78a2d9ce3f3fdcc2e78a34ac5f0` |
| libxml2 | 2.11.5 | https://download.gnome.org/sources/libxml2/2.11/libxml2-2.11.5.tar.xz | [libxml2-2.11.5.tar.xz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/libxml2-2.11.5.tar.xz) | `3727b078c360ec69fa869de14bd6f75d7ee8d36987b071e6928d4720a28df3a6` |
| dav1d | 1.2.1 | https://code.videolan.org/videolan/dav1d/-/archive/1.2.1/dav1d-1.2.1.tar.bz2 | [dav1d-1.2.1.tar.bz2](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/dav1d-1.2.1.tar.bz2) | `a4003623cdc0109dec3aac8435520aa3fb12c4d69454fa227f2658cdb6dab5fa` |
| libpng | 1.6.40 | https://downloads.sourceforge.net/project/libpng/libpng16/1.6.40/libpng-1.6.40.tar.xz | [libpng-1.6.40.tar.xz](https://github.com/TVGlowIPTV/video-libraries-source/releases/download/ios-libmpv-0.6.0/libpng-1.6.40.tar.xz) | `535b479b2467ff231a3ec6d92a525906fb8ef27978be4f66dbe05d3f3a01b3a1` |

FFmpeg is configured there without `--enable-gpl` and without
`--enable-nonfree`, and with `--enable-version3`; mpv with `-Dgpl=false`.
