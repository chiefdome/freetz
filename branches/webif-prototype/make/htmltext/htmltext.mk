$(call PKG_INIT_BIN, 0.0.01)
$(PKG)_SOURCE:=htmltext-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/not_yet
$(PKG)_DIR:=$(SOURCE_DIR)/htmltext-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/getText
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/getText

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(HTMLTEXT_DIR) \
		CROSS="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(HTMLTEXT_DIR) clean
	$(RM) $(HTMLTEXT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HTMLTEXT_TARGET_BINARY)

$(PKG_FINISH)
