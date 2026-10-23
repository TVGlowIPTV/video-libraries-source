# Using TVGlow for Android with a modified library

TVGlow for Android loads its FFmpeg audio decoders from one file,
`lib/<processor type>/libffmpegJNI.so` in the APK. It is a separate library,
not part of the program code.

To use a version you have built yourself, build `libffmpegJNI.so` from the
sources in this folder (with your changes to FFmpeg), put it in place of the
one in the APK for your device's processor type, and sign the APK again with
your own key. Your build must offer the same interface to the Media3 module as
the one it replaces (Media3 1.11.0's `ffmpeg_jni.cc`).
