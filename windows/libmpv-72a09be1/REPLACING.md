# Using TVGlow for Windows with a modified library

TVGlow for Windows loads the video libraries from one file, `libmpv-2.dll`,
which sits in the same folder as `TVGlow.exe`. It is a separate library, not
part of the program file.

To use a version you have built yourself, replace that file with your own
`libmpv-2.dll`. Your build must offer the same libmpv programming interface as
the one it replaces (libmpv from mpv 0.39).
