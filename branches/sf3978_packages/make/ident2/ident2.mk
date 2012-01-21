$(call PKG_INIT_BIN, v1.07_FINAL)
$(PKG)_SOURCE:=ident2-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.sourcefiles.org/System/Servers
$(PKG)_BINARY:=$($(PKG)_DIR)/ident2
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ident
$(PKG)_SOURCE_MD5:=be8e2d37a2a9338aeea9933ddda413e9

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(IDENT2_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(IDENT2_DIR) clean
	$(RM) $(IDENT2_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IDENT2_TARGET_BINARY)

$(PKG_FINISH)
