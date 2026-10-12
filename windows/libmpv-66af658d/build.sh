#!/usr/bin/env bash
# Run in Linux/WSL with the documented host tools installed. Never cleans output.
set -euo pipefail
owner=$(cd "$(dirname "$0")" && pwd)
work=${1:?Usage: bash build.sh /absolute/native-build-directory}
[[ "$work" == /* && "$work" != *' '* ]] || { echo 'Use an absolute Linux path without spaces.' >&2; exit 1; }
mkdir -p "$work"
cd "$work"
if [[ ! -d source ]]; then
  git clone --no-checkout https://github.com/media-kit/libmpv-win32-video-cmake.git source
  git -C source checkout --detach 8ddbe5472465950b87853789f7173f2eedc5586a
fi
[[ $(git -C source rev-parse HEAD) == 8ddbe5472465950b87853789f7173f2eedc5586a ]]
git -C source apply --reverse --check "$owner/recipe.patch" 2>/dev/null || git -C source apply "$owner/recipe.patch"
cp "$owner"/ffmpeg-tvglow-*.patch "$owner/libplacebo-tvglow-python314.patch" source/packages/

fetch() {
  local name=$1 hash=$2 url=$3
  [[ -f "$name" ]] || curl --fail --location "$url" --output "$name"
  printf '%s  %s\n' "$hash" "$name" | sha256sum --check -
}
fetch cmake-bin.tar.gz ba1e0dcc710e2f92be6263f9617510b3660fa9dc409ad2fb8190299563f952a0 \
  https://github.com/Kitware/CMake/releases/download/v3.26.4/cmake-3.26.4-linux-x86_64.tar.gz
fetch cmake-source.tar.gz 914cda29d02da8288c68b97368e4861f4b058eea7016d07af61876667a88f4fe \
  https://github.com/Kitware/CMake/releases/download/v3.26.4/cmake-3.26.4.tar.gz
[[ -d cmake-3.26.4-linux-x86_64 ]] || tar -xf cmake-bin.tar.gz
[[ -d cmake-3.26.4 ]] || tar -xf cmake-source.tar.gz
cd source
mkdir -p build/install/bin build/cmake326
if [[ ! -f build/cmake326/Modules/ExternalProject.cmake ]]; then
  cp -r ../cmake-3.26.4/Modules build/cmake326/
  (cd build/cmake326 && patch -p1 -i ../../packages/cmake-0001-ExternalProject-changes.patch)
fi
for tool in gcc g++ cpp as ar ranlib dlltool objcopy strip size strings nm readelf windres addr2line ld ld.bfd; do
  [[ -e build/install/bin/cross-$tool ]] || ln -s "$(command -v x86_64-w64-mingw32-$tool)" "build/install/bin/cross-$tool"
done
[[ -e build/install/bin/cross-c++ ]] || ln -s "$(command -v x86_64-w64-mingw32-g++)" build/install/bin/cross-c++
[[ -e build/install/bin/cmake ]] || ln -s "$work/cmake-3.26.4-linux-x86_64/bin/cmake" build/install/bin/cmake

rustup_exe=$(command -v rustup)
export RUSTUP_HOME="$PWD/build/install_rustup/.rustup"
export CARGO_HOME="$PWD/build/install_rustup/.cargo"
mkdir -p "$CARGO_HOME/bin"
for tool in rustup cargo rustc rustdoc; do
  [[ -e "$CARGO_HOME/bin/$tool" ]] || ln -s "$rustup_exe" "$CARGO_HOME/bin/$tool"
done
export PATH="$CARGO_HOME/bin:$PATH"
rustup toolchain install 1.90.0 --profile minimal --target x86_64-pc-windows-gnu
rustup default 1.90.0
if [[ ! -x "$CARGO_HOME/bin/cargo-cbuild" ]]; then
  PKG_CONFIG=pkgconf PKG_CONFIG_LIBDIR=/usr/lib/x86_64-linux-gnu/pkgconfig \
    cargo install cargo-c --version 0.10.16 --locked
fi
prefix="$PWD/build/install/x86_64-w64-mingw32"
build/install/bin/cmake -G Ninja -B build -S . \
  "-DGCC_FLAGS=-B$prefix/lib/ -I$prefix/include -L$prefix/lib -static-libgcc -static-libstdc++"
ninja -C build -j 2 gcc-wrapper
GIT_COMMITTER_NAME='TVGlow native build' GIT_COMMITTER_EMAIL=build@localhost ninja -C build -j 2 mpv
(cd build/packages/mpv-prefix/src/mpv-build && sha256sum --check "$owner/SHA256SUMS")
mkdir -p "$owner/build"
cp build/packages/mpv-prefix/src/mpv-build/libmpv-2.dll "$owner/build/"
