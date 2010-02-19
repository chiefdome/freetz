$(call PKG_INIT_BIN, 0.15.2b)
$(PKG)_SOURCE:=madplay-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=6814b47ceaa99880c754c5195aa1aac1
$(PKG)_SITE:=@SF/mad
$(PKG)_BINARY:=$($(PKG)_DIR)/madplay
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/madplay

# touch configure.ac to prevent aclocal.m4 & configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON := zlib libid3tag libmad

$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-profiling
$(PKG)_CONFIGURE_OPTIONS += --disable-debugging

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $(MADPLAY_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MADPLAY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(MADPLAY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MADPLAY_TARGET_BINARY)

$(PKG_FINISH)
