#!/usr/bin/env bash
# Run in Linux/WSL (x86_64). Never cleans output. See TVGLOW_PATCHES.md.
set -euo pipefail
owner=$(cd "$(dirname "$0")" && pwd)
work=${1:?Usage: bash build.sh /absolute/native-build-directory}
[[ "$work" == /* && "$work" != *' '* ]] || { echo 'Use an absolute Linux path without spaces.' >&2; exit 1; }
mkdir -p "$work"
cd "$work"

media_commit=2bc207851df311340767e913931ca7b28cab1794   # androidx/media tag 1.11.0
ffmpeg_commit=b08d7969c550a804a59511c7b83f2dd8cc0499b8  # FFmpeg n7.1, as on Windows
ndk_version=28.2.13676358                               # Flutter 3.41's flutter.ndkVersion
decoders=(ac3 eac3 dca truehd mlp)

fetch() {
  local name=$1 hash=$2 url=$3
  [[ -f "$name" ]] || curl --fail --location "$url" --output "$name"
  printf '%s  %s\n' "$hash" "$name" | sha256sum --check -
}
fetch jdk.tar.gz d8afc263758141a66e0e3aafc321e783f7016696f4eaea067d340a269037d331 \
  https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.19%2B10/OpenJDK17U-jdk_x64_linux_hotspot_17.0.19_10.tar.gz
fetch cmdline-tools.zip 4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583 \
  https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip
[[ -d jdk-17.0.19+10 ]] || tar -xf jdk.tar.gz
export JAVA_HOME="$work/jdk-17.0.19+10"
export ANDROID_HOME="$work/sdk"
if [[ ! -x sdk/cmdline-tools/latest/bin/sdkmanager ]]; then
  mkdir -p sdk/cmdline-tools
  rm -rf sdk/cmdline-tools/latest cmdline-tools
  unzip -q cmdline-tools.zip
  mv cmdline-tools sdk/cmdline-tools/latest
fi
# Accept the Android SDK licences yourself; this script never accepts them.
[[ -f sdk/licenses/android-sdk-license ]] || {
  echo "Accept the Android SDK licences first: $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses" >&2
  exit 1
}
sdk/cmdline-tools/latest/bin/sdkmanager --install "ndk;$ndk_version" "cmake;3.22.1" \
  "platforms;android-36" "build-tools;36.0.0" >/dev/null

if [[ ! -d media ]]; then
  git clone --no-checkout https://github.com/androidx/media.git media
  git -C media checkout --detach "$media_commit"
fi
[[ $(git -C media rev-parse HEAD) == "$media_commit" ]]
git -C media apply --reverse --check "$owner/media-tvglow.patch" 2>/dev/null || git -C media apply "$owner/media-tvglow.patch"

module="$work/media/libraries/decoder_ffmpeg/src/main"
if [[ ! -d "$module/jni/ffmpeg" ]]; then
  git clone --no-checkout https://git.ffmpeg.org/ffmpeg.git "$module/jni/ffmpeg"
  git -C "$module/jni/ffmpeg" checkout --detach "$ffmpeg_commit"
fi
[[ $(git -C "$module/jni/ffmpeg" rev-parse HEAD) == "$ffmpeg_commit" ]]
if [[ ! -f "$module/jni/ffmpeg/android-libs/x86_64/libavcodec.a" ]]; then
  # The upstream script's third argument names the NDK host; 23 is Media3's minSdk.
  (cd "$module/jni" && ./build_ffmpeg.sh "$module" "$ANDROID_HOME/ndk/$ndk_version" linux-x86_64 23 "${decoders[@]}")
fi

(cd media && ./gradlew --no-daemon :lib-decoder-ffmpeg:assembleRelease)
mkdir -p "$owner/build"
cp media/libraries/decoder_ffmpeg/buildout/outputs/aar/lib-decoder-ffmpeg-release.aar \
  "$owner/build/media3-decoder-ffmpeg-1.11.0.aar"
(cd "$owner/build" && sha256sum --check "$owner/SHA256SUMS")
