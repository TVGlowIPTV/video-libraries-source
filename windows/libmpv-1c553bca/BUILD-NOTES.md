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

## 2026-10-22: PGS and closed-caption decoders added; teletext left out

`recipe.patch` now also enables two
FFmpeg subtitle decoders:

- `pgssub`: Blu-ray PGS picture subtitles (mpv codec id `hdmv_pgs_subtitle`).
- `ccaption`: CEA-608 closed captions (FFmpeg's decoder is called `cc_dec`;
  mpv codec id `eia_608`). mpv creates the caption track from the captions
  carried in the video when `sub-create-cc-track` is set.

Both are FFmpeg's own LGPL code and need no other library.

Teletext (`libzvbi_teletext`) is not enabled. It needs libzvbi. In zvbi
v0.2.46 (`34bb6f66`), `COPYING.md` licenses `src/*` LGPL-2+ except
`src/packet-830.*` and `src/pdc.*`, which are GPL-2 only; `exp-vtx.c` also
carries a GPL-2+ header. All of these are in `libzvbi_la_SOURCES`, and
`packet.c`, which the teletext decoder runs, calls
`vbi_decode_teletext_8301_local_time` and `vbi_decode_teletext_8302_pdc` from
`packet-830.c`. A static link would therefore put GPL-2 code into the DLL,
against the "no GPL" rule above.

How the new DLL was made: in the same build tree and with the same toolchain
as the 2026-10-11 DLL, by regenerating the CMake step files and running the
tree's recorded step commands for FFmpeg (configure, build, install, in its
recorded build directory) and mpv (build, strip). No other library was
reconfigured or rebuilt. This is an incremental build, as before.

What was checked on the result:

- FFmpeg's configure output lists `ccaption` and `pgssub` under enabled
  decoders, and `config_components.h` has both set to 1;
  `CONFIG_LIBZVBI_TELETEXT_DECODER`, `CONFIG_TRUEHD_DECODER` and
  `CONFIG_MLP_DECODER` stay 0.
- The enabled subtitle decoders are now `ass`, `ccaption`, `dvbsub`, `dvdsub`,
  `movtext`, `pgssub`, `srt`, `stl`, `subrip`, `subviewer`, `subviewer1`,
  `text`, `vplayer` and `webvtt`.
- The DLL imports the same set of Windows system libraries as the
  2026-10-11 DLL and exports the same 56 `mpv_*` functions.
- Loaded on Windows with Python `ctypes`: client API 2.3, `mpv-version`
  v0.39.0, `ffmpeg-version` n7.1, `mpv_initialize` returns 0. Its
  audio/video `decoder-list` has 135 entries for 113 codecs, the same as the
  2026-10-11 DLL (AC-3, E-AC-3, DTS, H.264, HEVC present; TrueHD absent).
  mpv does not list subtitle decoders there.
- `recipe.patch` reverse-applies cleanly to the build tree.

Checksums: the previous DLL was
`66af658de0f6b76f82bf9ed7384a24349c750e5245b4ae74f72ec467e1c0ef0c`
(41,782,784 bytes); the new one in `SHA256SUMS` is
`935acb39d7f619010f969ae7f968cc0c2b462ee6fe16212212051772dbedde2e`
(41,793,024 bytes). Not yet checked: PGS and CEA-608 pixels on screen in a
Windows build, and the earlier playback probes with this DLL.

## 2026-10-22: teletext through an LGPL-only zvbi

This entry adds
DVB teletext subtitles. It builds on the PGS/closed-caption entry above and
does not include TrueHD.

zvbi is patched to remove its GPL-2 `packet-830` and `pdc` files and its
GPL-2+ `exp-vtx` file.

- `recipe.patch` pins zvbi v0.2.46 (`34bb6f660c5c1bacd4a66cc7b22311e4ca3c1ab5`;
  the recipe tracked `main` before) and applies
  `zvbi-tvglow-lgpl-only.patch`. That patch builds libzvbi from its LGPL files
  only:
  - `src/packet-830.*` and `src/pdc.*` (GPL-2 in zvbi's `COPYING.md`) and
    `src/exp-vtx.c` (GPL-2+ header) leave the library and `libzvbi.h`.
  - `packet.c` ignores Teletext packet 8/30 format 1 (local time) and
    format 2 (PDC) and no longer decodes VPS program IDs.
  - The PDC functions in `vps.c` go, and so do the program-ID members in
    `vbi.h`, `vbi.c` and `event.h`.
  - Teletext pages and subtitles do not use any of these.
  - FFmpeg's teletext decoder registers neither of the two events that are
    lost (`VBI_EVENT_LOCAL_TIME`, `VBI_EVENT_PROG_ID`).
- zvbi's configure is told there is no libpng
  (`ac_cv_lib_png_png_destroy_write_struct=no`), so PNG page export is not
  built. zvbi no longer depends on libpng. It needs only GNU libiconv, which
  the DLL already carries, and the Windows system libraries.
- FFmpeg gets `--enable-libzvbi` and `--enable-decoder=libzvbi_teletext`,
  without `--enable-gpl`. FFmpeg's configure accepts zvbi ≥ 0.2.28 without
  GPL.
- mpv sets the decoder itself:
  - `sd_lavc` asks for the teletext subtitle page by default
    (`txt_page=subtitle`, or `--teletext-page`);
  - it draws the decoder's default bitmap output like DVB subtitles;
  - its text path asks for `txt_format=ass`.
  - No TVGlow decoder option is needed.
- `build.sh` copies the zvbi patch and runs `check_zvbi_licences.py` after the
  build.

How the DLL was made, in the same tree as the entries above:

1. FFmpeg's configuration was set back from the TrueHD build: the
   `truehd`/`mlp` decoder and `mlp` parser lines were removed again, and the
   libzvbi lines were added.
2. libzvbi was built through its recorded steps (`ninja -C build libzvbi`:
   clone at the pinned commit, patch, autogen/configure, build, install).
3. The CMake step files were regenerated, and FFmpeg's recorded configure,
   build and install steps were run in its build directory.
4. mpv's Meson setup was redone with the recipe's own
   `force-meson-configure` and `configure` steps, so that it picks up
   `libzvbi.a` from `libavcodec.pc`. Then the mpv build and strip steps were
   run.

Licence scan (`check_zvbi_licences.py`):

- It lists every object in `libzvbi.a` (`ar t`).
- For each object it reads the compiler's dependency file, which gives the
  source file and every header that source included.
- It classifies each zvbi file by its own licence header, or by
  `COPYING.md` where a file has none.
- It fails on any GPL-only, GPL-2+ or unclassified file, and on any file the
  patch removes.
- Two top-level files are written by configure:
  - `config.h` is autoconf output;
  - `site_def.h` is accepted only while, with comments removed, it holds
    nothing but its include guard.
- Headers from outside the zvbi tree are listed but not classified. They are
  GCC's own headers, the MinGW-w64 headers and GNU libiconv's `iconv.h`.

Output on the built library:

<details><summary>Scan output (42 objects, 95 zvbi files, PASS)</summary>

```
libzvbi.a members: 42
  bit_slicer.o                     <- src/bit_slicer.c
  cache.o                          <- src/cache.c
  caption.o                        <- src/caption.c
  cc608_decoder.o                  <- src/cc608_decoder.c
  conv.o                           <- src/conv.c
  dvb_mux.o                        <- src/dvb_mux.c
  dvb_demux.o                      <- src/dvb_demux.c
  event.o                          <- src/event.c
  exp-html.o                       <- src/exp-html.c
  exp-templ.o                      <- src/exp-templ.c
  exp-txt.o                        <- src/exp-txt.c
  export.o                         <- src/export.c
  hamm.o                           <- src/hamm.c
  idl_demux.o                      <- src/idl_demux.c
  inout.o                          <- src/inout.c
  io-bktr.o                        <- src/io-bktr.c
  io-dvb.o                         <- src/io-dvb.c
  io-sim.o                         <- src/io-sim.c
  io-v4l.o                         <- src/io-v4l.c
  io-v4l2.o                        <- src/io-v4l2.c
  io-v4l2k.o                       <- src/io-v4l2k.c
  lang.o                           <- src/lang.c
  misc.o                           <- src/misc.c
  packet.o                         <- src/packet.c
  teletext.o                       <- src/teletext.c
  page_table.o                     <- src/page_table.c
  pfc_demux.o                      <- src/pfc_demux.c
  proxy-client.o                   <- src/proxy-client.c
  raw_decoder.o                    <- src/raw_decoder.c
  sampling_par.o                   <- src/sampling_par.c
  search.o                         <- src/search.c
  ure.o                            <- src/ure.c
  sliced_filter.o                  <- src/sliced_filter.c
  tables.o                         <- src/tables.c
  trigger.o                        <- src/trigger.c
  vbi.o                            <- src/vbi.c
  vps.o                            <- src/vps.c
  wss.o                            <- src/wss.c
  xds_demux.o                      <- src/xds_demux.c
  strptime.o                       <- src/strptime.c
  libzvbiinline_la-decoder.o       <- src/decoder.c
  libzvbiinline_la-exp-gfx.o       <- src/exp-gfx.c

zvbi files compiled into the archive (sources and headers): 95
  ok   config.h                     generated by configure (autoconf output)
  ok   site_def.h                   written by configure; include guard only, no code
  ok   src/bcd.h                    LGPL (header)
  ok   src/bit_slicer.c             LGPL (header)
  ok   src/bit_slicer.h             LGPL (header)
  ok   src/cache-priv.h             LGPL (header)
  ok   src/cache.c                  LGPL (header)
  ok   src/cache.h                  LGPL (header)
  ok   src/caption.c                LGPL (header)
  ok   src/cc.h                     LGPL (header)
  ok   src/cc608_decoder.c          LGPL (header)
  ok   src/cc608_decoder.h          LGPL (header)
  ok   src/ccfont2.xbm              LGPL (header)
  ok   src/conv.c                   LGPL (header)
  ok   src/conv.h                   LGPL (header)
  ok   src/decoder.c                LGPL (header)
  ok   src/decoder.h                LGPL (header)
  ok   src/dlist.h                  LGPL (header)
  ok   src/dvb.h                    LGPL (header)
  ok   src/dvb_demux.c              LGPL (header)
  ok   src/dvb_demux.h              LGPL (header)
  ok   src/dvb_mux.c                LGPL (header)
  ok   src/dvb_mux.h                LGPL (header)
  ok   src/event-priv.h             LGPL (header)
  ok   src/event.c                  LGPL (header)
  ok   src/event.h                  LGPL (header)
  ok   src/exp-gfx.c                LGPL (header)
  ok   src/exp-gfx.h                LGPL (header)
  ok   src/exp-html.c               LGPL (header)
  ok   src/exp-templ.c              LGPL-2+ (COPYING.md)
  ok   src/exp-txt.c                LGPL (header)
  ok   src/exp-txt.h                LGPL (header)
  ok   src/export.c                 LGPL (header)
  ok   src/export.h                 LGPL (header)
  ok   src/format.h                 LGPL (header)
  ok   src/hamm-tables.h            LGPL (header)
  ok   src/hamm.c                   LGPL (header)
  ok   src/hamm.h                   LGPL (header)
  ok   src/idl_demux.c              LGPL (header)
  ok   src/idl_demux.h              LGPL (header)
  ok   src/inout.c                  LGPL (header)
  ok   src/inout.h                  LGPL (header)
  ok   src/intl-priv.h              LGPL (header)
  ok   src/io-bktr.c                LGPL (header)
  ok   src/io-dvb.c                 LGPL (header)
  ok   src/io-sim.c                 LGPL (header)
  ok   src/io-sim.h                 LGPL (header)
  ok   src/io-v4l.c                 LGPL (header)
  ok   src/io-v4l2.c                LGPL (header)
  ok   src/io-v4l2k.c               LGPL (header)
  ok   src/lang.c                   LGPL (header)
  ok   src/lang.h                   LGPL (header)
  ok   src/macros.h                 LGPL (header)
  ok   src/misc.c                   LGPL (header)
  ok   src/misc.h                   LGPL (header)
  ok   src/network-table.h          LGPL-2+ (COPYING.md)
  ok   src/network.h                LGPL (header)
  ok   src/packet.c                 LGPL (header)
  ok   src/page_table.c             LGPL (header)
  ok   src/page_table.h             LGPL (header)
  ok   src/pfc_demux.c              LGPL (header)
  ok   src/pfc_demux.h              LGPL (header)
  ok   src/proxy-client.c           LGPL (header)
  ok   src/proxy-client.h           LGPL (header)
  ok   src/proxy-msg.h              LGPL (header)
  ok   src/raw_decoder.c            LGPL (header)
  ok   src/raw_decoder.h            LGPL (header)
  ok   src/sampling_par.c           LGPL (header)
  ok   src/sampling_par.h           LGPL (header)
  ok   src/search.c                 LGPL (header)
  ok   src/search.h                 LGPL (header)
  ok   src/sliced.h                 LGPL (header)
  ok   src/sliced_filter.c          LGPL (header)
  ok   src/sliced_filter.h          LGPL (header)
  ok   src/strptime.c               LGPL (header)
  ok   src/strptime.h               LGPL (header)
  ok   src/tables.c                 LGPL (header)
  ok   src/tables.h                 LGPL (header)
  ok   src/teletext.c               LGPL (header)
  ok   src/teletext_decoder.h       LGPL (header)
  ok   src/trigger.c                LGPL (header)
  ok   src/trigger.h                LGPL (header)
  ok   src/ure.c                    permissive (header)
  ok   src/ure.h                    permissive (header)
  ok   src/vbi.c                    LGPL (header)
  ok   src/vbi.h                    LGPL (header)
  ok   src/version.h                LGPL-2+ (COPYING.md)
  ok   src/vps.c                    LGPL (header)
  ok   src/vps.h                    LGPL (header)
  ok   src/vt.h                     LGPL (header)
  ok   src/wss.c                    LGPL (header)
  ok   src/wss.h                    LGPL (header)
  ok   src/wstfont2.xbm             LGPL (header)
  ok   src/xds_demux.c              LGPL (header)
  ok   src/xds_demux.h              LGPL (header)

headers from outside the zvbi tree: 304, under <build tree>/build/install/x86_64-w64-mingw32/include, /usr/lib, /usr/share/mingw-w64/include

RESULT: PASS - no GPL-only or GPL-2+ zvbi file is compiled into libzvbi.a
```

</details>

Other new dependencies: none. libzvbi's `zvbi-0.2.pc` links `-lpthread`
(winpthreads, already in the DLL), `-lws2_32` (Windows) and `-liconv` (GNU
libiconv, already in the DLL and in the notices).

What was checked on the result:

- FFmpeg's configure output lists `libzvbi` among external libraries and
  `libzvbi_teletext` among enabled decoders, with `pgssub` and `ccaption`.
- `config.h` has `CONFIG_LIBZVBI 1`, and `config_components.h` has
  `CONFIG_LIBZVBI_TELETEXT_DECODER 1`.
- `CONFIG_TRUEHD_DECODER` and `CONFIG_MLP_DECODER` are 0. `CONFIG_MLP_PARSER`
  is 1, as before: the TrueHD demuxer selects it.
- The DLL imports the same set of Windows system libraries as the earlier
  DLLs and exports the same 56 `mpv_*` functions.
- 154 zvbi symbols are linked, and none of them comes from the removed files
  (no `vbi_decode_teletext_830*`, `vbi_pil_*`, `vbi_program_id_*`, PDC or
  `vbi_export_class_vtx` symbol in `mpv.debug`).
- Loaded on Windows with Python `ctypes`: client API 2.3, mpv v0.39.0, FFmpeg
  n7.1, and `mpv_initialize` returns 0. The audio/video `decoder-list` has 135
  entries, the same as the DLL without TrueHD.
- `recipe.patch` reverse-applies cleanly to the build tree, and
  `zvbi-tvglow-lgpl-only.patch` reverse-applies cleanly to the built zvbi
  source.

Checksums: the DLL this builds on (PGS and closed captions) is
`935acb39d7f619010f969ae7f968cc0c2b462ee6fe16212212051772dbedde2e`. The new one
in `SHA256SUMS` is
`1c553bcaea2985433740731948cd57bb65fac40cda85348b42e1f1069702fde6`
(42,014,208 bytes).

Not yet checked: teletext subtitles on screen and in time from a TS with a DVB
teletext subtitle page, in a Windows build.
