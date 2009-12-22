$(call PKG_INIT_BIN, 0.1)

$(PKG)_BINARY_NAME_LFS:=target-tester-lfs
$(PKG)_BINARY_LFS:=$($(PKG)_DIR)/$($(PKG)_BINARY_NAME_LFS)
$(PKG)_TARGET_BINARY_LFS:=$($(PKG)_DEST_DIR)/usr/bin/$($(PKG)_BINARY_NAME_LFS)

$(PKG)_BINARY_NAME_NOLFS:=target-tester-nolfs
$(PKG)_BINARY_NOLFS:=$($(PKG)_DIR)/$($(PKG)_BINARY_NAME_NOLFS)
$(PKG)_TARGET_BINARY_NOLFS:=$($(PKG)_DEST_DIR)/usr/bin/$($(PKG)_BINARY_NAME_NOLFS)

TARGET_CFLAGS_WITHOUT_LARGEFILE_FLAGS:=$(strip $(subst $(CFLAGS_LARGEFILE),,$(TARGET_CFLAGS)))

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

define TARGET_TESTER_COMPILE_BINARY
$(1): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TARGET_TESTER_DIR) \
		TARGET=$$(notdir $$@) \
		CC="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS_WITHOUT_LARGEFILE_FLAGS) $(2)"
endef

$(eval $(call TARGET_TESTER_COMPILE_BINARY,$($(PKG)_BINARY_LFS),$(CFLAGS_LFS_ENABLED) -DINCLUDE_LFS_ONLY_TYPES))
$(eval $(call TARGET_TESTER_COMPILE_BINARY,$($(PKG)_BINARY_NOLFS),$(CFLAGS_LFS_DISABLED)))

$($(PKG)_TARGET_BINARY_LFS): $($(PKG)_BINARY_LFS)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY_NOLFS): $($(PKG)_BINARY_NOLFS)
	$(INSTALL_BINARY_STRIP)

$(pkg)-math-functions: $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TARGET_TESTER_DIR) \
		CC="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib" \
		math-functions

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY_LFS) $($(PKG)_TARGET_BINARY_NOLFS)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TARGET_TESTER_DIR) TARGET=$(TARGET_TESTER_BINARY_NAME_LFS) clean
	-$(SUBMAKE) -C $(TARGET_TESTER_DIR) TARGET=$(TARGET_TESTER_BINARY_NAME_NOLFS) clean

$(pkg)-uninstall:
	$(RM) $(TARGET_TESTER_TARGET_BINARY_LFS) $(TARGET_TESTER_TARGET_BINARY_NOLFS)

$(PKG_FINISH)
