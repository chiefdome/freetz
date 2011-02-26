$(call PKG_INIT_BIN,0.12.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=e927dd5dc52d3cfcebd8ca1af6f0d3c2
$(PKG)_SITE:=@SF/mediatomb

$(PKG)_BINARY:=$($(PKG)_DIR)/build/mediatomb
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/mediatomb
$(PKG)_SHARE_DIR:=/usr/share/mediatomb
$(PKG)_TARGET_WEBIF:=$($(PKG)_DEST_DIR)$($(PKG)_SHARE_DIR)/web/index.html

$(PKG)_DEPENDS_ON += uclibcxx curl expat ffmpeg libexif sqlite zlib
ifeq ($(strip $(FREETZ_PACKAGE_MEDIATOMB_WITH_PLAYLIST_SUPPORT)),y)
$(PKG)_DEPENDS_ON += js
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MEDIATOMB_WITH_PLAYLIST_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MEDIATOMB_STATIC

$(PKG)_CONFIGURE_OPTIONS += --disable-rpl-malloc
$(PKG)_CONFIGURE_OPTIONS += --enable-pthread-lib

$(PKG)_CONFIGURE_OPTIONS += --enable-curl
$(PKG)_CONFIGURE_OPTIONS += --enable-ffmpeg
$(PKG)_CONFIGURE_OPTIONS += --enable-inotify
$(PKG)_CONFIGURE_OPTIONS += --enable-libexif
$(PKG)_CONFIGURE_OPTIONS += --enable-sqlite3
$(PKG)_CONFIGURE_OPTIONS += --enable-taglib
$(PKG)_CONFIGURE_OPTIONS += --enable-youtube
$(PKG)_CONFIGURE_OPTIONS += --enable-zlib

$(PKG)_INSTALL_SUBDIRS := config web
ifeq ($(strip $(FREETZ_PACKAGE_MEDIATOMB_WITH_PLAYLIST_SUPPORT)),y)
$(PKG)_INSTALL_SUBDIRS   += scripts/js
$(PKG)_CONFIGURE_OPTIONS += --enable-libjs
$(PKG)_CONFIGURE_OPTIONS += --with-js-h="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/js"
$(PKG)_CONFIGURE_OPTIONS += --with-js-libs="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
else
$(PKG)_CONFIGURE_OPTIONS += --disable-libjs
endif

$(PKG)_CONFIGURE_OPTIONS += --disable-ffmpegthumbnailer
$(PKG)_CONFIGURE_OPTIONS += --disable-id3lib
$(PKG)_CONFIGURE_OPTIONS += --disable-lastfmlib
$(PKG)_CONFIGURE_OPTIONS += --disable-libextractor
$(PKG)_CONFIGURE_OPTIONS += --disable-libmagic
$(PKG)_CONFIGURE_OPTIONS += --disable-libmp4v2
$(PKG)_CONFIGURE_OPTIONS += --disable-mysql

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MEDIATOMB_DIR) \
	$(if $(FREETZ_PACKAGE_MEDIATOMB_STATIC),LDFLAGS="-static" STATIC_LINKING_LIBS="-lavcodec -lavutil -lssl -lcrypto -ldl -lz -lm")

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_WEBIF): $($(PKG)_BINARY)
	$(foreach d,$(MEDIATOMB_INSTALL_SUBDIRS),$(SUBMAKE) -C $(MEDIATOMB_DIR)/$(d) DESTDIR="$(abspath $(MEDIATOMB_DEST_DIR))" install;)
	$(RM) $(MEDIATOMB_DEST_DIR)$(MEDIATOMB_SHARE_DIR)/mysql.sql
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_WEBIF)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MEDIATOMB_DIR) clean
	$(MEDIATOMB_DIR)/.configured

$(pkg)-uninstall:
	$(RM) -r $(MEDIATOMB_TARGET_BINARY) $(MEDIATOMB_DEST_DIR)$(MEDIATOMB_SHARE_DIR)

$(PKG_FINISH)
