$(call PKG_INIT_BIN,02.24.36)
$(PKG)_SOURCE:=$(pkg).v.$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=14c044a2754417b344be364eeccc6779
$(PKG)_SITE:=@SF/inadyn-mt

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg).v.$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/inadyn-mt
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/inadyn-mt


$(PKG)_CONFIGURE_OPTIONS += --disable-sound
$(PKG)_CONFIGURE_OPTIONS += --enable-threads
#$(PKG)_CONFIGURE_OPTIONS += --enable-debug

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(INADYN_MT_DIR) \
		inadyn_mt_CFLAGS="" \
		inadyn_mt_LDFLAGS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(INADYN_MT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(INADYN_MT_TARGET_BINARY)

$(PKG_FINISH)
