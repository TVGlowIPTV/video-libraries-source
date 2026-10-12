# How this libmpv-2.dll was built

The library is built from the `media-kit/libmpv-win32-video-cmake` video recipe
at commit `8ddbe5472465950b87853789f7173f2eedc5586a` (20241021), changed by
`recipe.patch`, which pins every dependency to an exact commit and adapts the
build to a packaged MinGW toolchain.

- mpv v0.39.0 (`a0fba7be57f3822d967b04f0f6b6d6341e7516e7`)
- FFmpeg n7.1 (`b08d7969c550a804a59511c7b83f2dd8cc0499b8`) with three patches

## Our changes

- `ffmpeg-tvglow-380a518c439d4e5e3cf17b97e4a06259e8048f99.patch` and
  `ffmpeg-tvglow-e8c94e31da65856920434813368956640c771684.patch`: two upstream
  FFmpeg commits, backported. They reset MOV fragment state after an HLS seek
  and free its nested stream information. Each keeps its original author.
- `ffmpeg-tvglow-combined.patch`: those two together with the recipe's own
  DASH base-URL patch, so that an already patched source tree can be checked
  by reversing one patch.
- `libplacebo-tvglow-python314.patch`: passes an XML root element to
  ElementTree in a build script, for Python 3.14.
- `recipe.patch`: the dependency pins; DVD input libraries removed from
  FFmpeg's dependencies; LZO compression turned off in libarchive; static link
  flags; Little CMS built without its `fast_float` and `threaded` plugins.

## Configuration

mpv is configured with `-Dgpl=false`. FFmpeg is configured with
`--disable-gpl --disable-nonfree --enable-version3`, so its libraries are
under the GNU Lesser General Public License, version 3 or later. Everything is
linked statically into the one DLL; the DLL imports only Windows system
libraries.

## Rebuilding

Use Linux x64 or WSL, with a build directory on a Linux file system and no
spaces in its path. The build that produced this DLL used Ubuntu 26.04, GCC
MinGW POSIX 13.2.0, MinGW headers and runtime 13.0.0, Python 3.14, and Rust
1.90.0 with cargo-c 0.10.16. Install rustup and these packages first:

```sh
sudo apt-get install build-essential ninja-build meson nasm yasm pkg-config \
  autoconf automake autopoint libtool-bin gettext bison flex texinfo gperf \
  curl unzip p7zip-full libgmp-dev libmpfr-dev libmpc-dev libssl-dev \
  python3-mako python3-jinja2 python3-docutils clang rst2pdf \
  gcc-mingw-w64-x86-64-posix g++-mingw-w64-x86-64-posix mingw-w64-x86-64-dev
bash build.sh /absolute/linux/native-build-directory
```

`build.sh` fetches the recipe at its pinned commit, applies `recipe.patch` and
the patches beside it, builds, and compares the result with `SHA256SUMS`. The
recipe downloads each library from its upstream repository at the pinned
commit; the same sources are attached to this release as archives, listed in
`SOURCES.md`.

A different host or toolchain can produce a DLL with a different checksum that
is still a correct build. The DLL named in `SHA256SUMS` was produced by an
incremental build in one tree, not by a single clean run of the script.
