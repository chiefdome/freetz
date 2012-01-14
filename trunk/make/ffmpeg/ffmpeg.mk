$(call PKG_INIT_BIN, 0.8.10)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=e64d6362df6a1aafb02e8458efd30d72
$(PKG)_SITE:=http://www.ffmpeg.org/releases

$(PKG)_DEPENDS_ON := zlib
ifeq ($(strip $(FREETZ_PACKAGE_FFMPEG_DECODER_libopenjpeg)),y)
$(PKG)_DEPENDS_ON += openjpeg
endif

$(PKG)_BINARIES_ALL        := ffmpeg ffserver
$(PKG)_BINARIES            := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIBNAMES_SHORT      := avcodec avdevice avfilter avformat avutil postproc swscale
$(PKG)_LIBVERSIONS_MAJOR   := 53      53       2        53       51     51       2
$(PKG)_LIBVERSIONS_MINOR   := 8.0     1.1      23.0     5.0      9.1    2.0      0.0

$(PKG)_LIBNAMES_LONG_MAJOR := $(join $($(PKG)_LIBNAMES_SHORT:%=lib%.so.),$($(PKG)_LIBVERSIONS_MAJOR))
$(PKG)_LIBNAMES_LONG       := $(join $($(PKG)_LIBNAMES_LONG_MAJOR:%=%.),$($(PKG)_LIBVERSIONS_MINOR))
$(PKG)_LIBS_BUILD_DIR      := $(join $($(PKG)_LIBNAMES_SHORT:%=$($(PKG)_DIR)/lib%/),$($(PKG)_LIBNAMES_LONG_MAJOR))
$(PKG)_LIBS_STAGING_DIR    := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR     := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_LIBDIR)/%)

$(PKG)_ENCODERS  := ac3 jpegls mjpeg mpeg1video mpeg2video mpeg4 pcm_s16be pcm_s16le png vorbis zlib
$(PKG)_DECODERS  := aac ac3 atrac3 gif h264 jpegls libopenjpeg mjpeg mjpegb mp2 mp3 mpeg1video mpeg2video mpeg4 mpegvideo pcm_s16be pcm_s16le png vorbis wmav1 wmav2 zlib
$(PKG)_MUXERS    := ac3 avi ffm flv h264 matroska mjpeg mp3 mp4 mpeg1video mpeg2video mpegts ogg rtp
$(PKG)_DEMUXERS  := ac3 avi ffm flv h264 image2 matroska mjpeg mp3 mpegps mpegts mpegvideo ogg rm rtsp sdp v4l2
$(PKG)_PARSERS   := aac ac3 h264 mjpeg mpegaudio mpegvideo mpeg4video
$(PKG)_PROTOCOLS := file http pipe rtp tcp udp

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FFMPEG_ffmpeg
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FFMPEG_ffserver
$(foreach i,encoder decoder muxer demuxer parser protocol, \
	$(eval $(PKG)_REBUILD_SUBOPTS += $(patsubst %,FREETZ_PACKAGE_FFMPEG_$(call TOUPPER_NAME,$(i))_%,$($(PKG)_$(call TOUPPER_NAME,$(i))S))) \
	$(eval $(PKG)_CONFIGURE_$(call TOUPPER_NAME,$(i))S := $(foreach c,$($(PKG)_$(call TOUPPER_NAME,$(i))S),$(if $(FREETZ_PACKAGE_FFMPEG_$(call TOUPPER_NAME,$(i))_$(c)),--enable-$(i)="$(c)"))) \
)

$(PKG)_CONFIGURE_DEFOPTS := n

$(PKG)_CONFIGURE_OPTIONS += --enable-cross-compile
$(PKG)_CONFIGURE_OPTIONS += --cross-prefix="$(TARGET_CROSS)"
$(PKG)_CONFIGURE_OPTIONS += --arch="$(TARGET_ARCH)"
$(PKG)_CONFIGURE_OPTIONS += --target-os=linux
$(PKG)_CONFIGURE_OPTIONS += --prefix="/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-debug

$(PKG)_CONFIGURE_OPTIONS += --enable-gpl
$(PKG)_CONFIGURE_OPTIONS += --enable-version3

$(PKG)_CONFIGURE_OPTIONS += --disable-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-dxva2
$(PKG)_CONFIGURE_OPTIONS += --disable-mmx
$(PKG)_CONFIGURE_OPTIONS += --disable-mmx2
$(PKG)_CONFIGURE_OPTIONS += --enable-pthreads
$(PKG)_CONFIGURE_OPTIONS += --disable-optimizations
$(PKG)_CONFIGURE_OPTIONS += --enable-small
$(PKG)_CONFIGURE_OPTIONS += --disable-stripping
$(PKG)_CONFIGURE_OPTIONS += --enable-zlib
$(PKG)_CONFIGURE_OPTIONS += --enable-postproc
$(PKG)_CONFIGURE_OPTIONS += --enable-swscale
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_FFMPEG_DECODER_libopenjpeg),--enable-libopenjpeg,--disable-libopenjpeg)

$(PKG)_CONFIGURE_OPTIONS += --disable-bsfs
$(PKG)_CONFIGURE_OPTIONS += --disable-devices
$(PKG)_CONFIGURE_OPTIONS += --disable-filters
$(PKG)_CONFIGURE_OPTIONS += --disable-hwaccels

$(PKG)_CONFIGURE_OPTIONS += --disable-encoders
$(PKG)_CONFIGURE_OPTIONS += --disable-decoders
$(PKG)_CONFIGURE_OPTIONS += --disable-muxers
$(PKG)_CONFIGURE_OPTIONS += --disable-demuxers
$(PKG)_CONFIGURE_OPTIONS += --disable-parsers
$(PKG)_CONFIGURE_OPTIONS += --disable-protocols
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_ENCODERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_DECODERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_MUXERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_DEMUXERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_PARSERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_PROTOCOLS)

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_FFMPEG_ffmpeg),--enable-ffmpeg,--disable-ffmpeg)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_FFMPEG_ffserver),--enable-ffserver,--disable-ffserver)
$(PKG)_CONFIGURE_OPTIONS += --disable-ffplay
$(PKG)_CONFIGURE_OPTIONS += --disable-ffprobe


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FFMPEG_DIR) V=1

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(FFMPEG_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(call PKG_FIX_LIBTOOL_LA,prefix) $(FFMPEG_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/lib%.pc)
	$(RM) -r $(FFMPEG_BINARIES_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/%) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/ffmpeg

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(FFMPEG_DIR) clean
	$(RM) -r \
		$(FFMPEG_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lib%) \
		$(FFMPEG_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/lib%.pc) \
		$(FFMPEG_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%*)

$(pkg)-uninstall:
	$(RM) $(FFMPEG_BINARIES_ALL:%=$(FFMPEG_DEST_DIR)/usr/bin/%) $(FFMPEG_LIBNAMES_SHORT:%=$(FFMPEG_TARGET_LIBDIR)/lib%*)

$(PKG_FINISH)
