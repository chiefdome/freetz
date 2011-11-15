$(call PKG_INIT_BIN, 0.0.1)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON := libevent
$(PKG)_FLAGS := -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr -L/usr/lib/freetz

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TRANSOCKSEV_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(TRANSOCKSEV_FLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TRANSOCKSEV_DIR) clean
	 $(RM) $(TRANSOCKSEV_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(TRANSOCKSEV_TARGET_BINARY)

$(PKG_FINISH)
