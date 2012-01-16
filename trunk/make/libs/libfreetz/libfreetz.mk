$(call PKG_INIT_LIB, 0.5)
$(PKG)_LIB_VERSION:=1.0.0

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_LIB)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBFREETZ_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -fPIC" \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBFREETZ_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBFREETZ_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libfreetz*

$(pkg)-uninstall:
	$(RM) $(LIBFREETZ_DEST_LIB)/libfreetz*.so*

$(PKG_FINISH)
