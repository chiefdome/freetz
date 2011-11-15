$(call PKG_INIT_BIN, 0.0.6.3)
$(PKG)_SOURCE:=LamaHub-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ea0d31a1c6245ed092377b7d60abdf22
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_DIR:=$(SOURCE_DIR)/$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/server
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lamahub

$(PKG)_LIBS := -ldl -lcrypt -lz

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(LAMAHUB_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DZPIPE" \
		CLIBS="$(LAMAHUB_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LAMAHUB_DIR) clean
	$(RM) $(LAMAHUB_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(LAMAHUB_TARGET_BINARY)

$(PKG_FINISH)
