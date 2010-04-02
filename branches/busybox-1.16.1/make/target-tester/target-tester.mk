$(call PKG_INIT_BIN, 0.1)

$(PKG)_BINARY_NAME_LFS:=target-tester-lfs
$(PKG)_BINARY_LFS:=$($(PKG)_DIR)/$($(PKG)_BINARY_NAME_LFS)
$(PKG)_TARGET_BINARY_LFS:=$($(PKG)_DEST_DIR)/usr/bin/$($(PKG)_BINARY_NAME_LFS)

$(PKG)_BINARY_NAME_NOLFS:=target-tester-nolfs
$(PKG)_BINARY_NOLFS:=$($(PKG)_DIR)/$($(PKG)_BINARY_NAME_NOLFS)
$(PKG)_TARGET_BINARY_NOLFS:=$($(PKG)_DEST_DIR)/usr/bin/$($(PKG)_BINARY_NAME_NOLFS)

$(PKG)_BINARIES:=ac_cv_func_mmap_fixed_mapped gt_cv_int_divbyzero_sigfpe
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

TARGET_CFLAGS_WITHOUT_LARGEFILE_FLAGS:=$(strip $(subst $(CFLAGS_LARGEFILE),,$(TARGET_CFLAGS)))

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

define TARGET_TESTER_COMPILE_BINARY
$(1): $($(PKG)_DIR)/.configured
	$(MAKE_ENV) \
		$(MAKE) -C $(TARGET_TESTER_DIR) \
		TARGET=$$(notdir $$@) \
		PREREQUISITE=$(2) \
		CC="$(3)" \
		CFLAGS="$(TARGET_CFLAGS_WITHOUT_LARGEFILE_FLAGS) $(4)"
endef

$(eval $(call TARGET_TESTER_COMPILE_BINARY,$($(PKG)_BINARY_LFS),target-tester,$(TARGET_CC),$(CFLAGS_LFS_ENABLED) -DINCLUDE_LFS_ONLY_TYPES))
$(eval $(call TARGET_TESTER_COMPILE_BINARY,$($(PKG)_BINARY_NOLFS),target-tester,$(TARGET_CC),$(CFLAGS_LFS_DISABLED)))
$(foreach binary,$($(PKG)_BINARIES), \
	$(eval $(call TARGET_TESTER_COMPILE_BINARY,$($(PKG)_DIR)/$(binary),$(binary),$(TARGET_CC),$(CFLAGS_LFS_ENABLED))) \
)


$($(PKG)_TARGET_BINARY_LFS) $($(PKG)_TARGET_BINARY_NOLFS) $($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg)-math-functions: $($(PKG)_DIR)/.configured
	$(MAKE_ENV) \
		$(MAKE) -C $(TARGET_TESTER_DIR) \
		CC="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib" \
		math-functions

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY_LFS) $($(PKG)_TARGET_BINARY_NOLFS) $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(MAKE_ENV) $(MAKE) -C $(TARGET_TESTER_DIR) TARGET=$(TARGET_TESTER_BINARY_NAME_LFS) clean
	-$(MAKE_ENV) $(MAKE) -C $(TARGET_TESTER_DIR) TARGET=$(TARGET_TESTER_BINARY_NAME_NOLFS) clean

$(pkg)-uninstall:
	$(RM) $(TARGET_TESTER_TARGET_BINARY_LFS) $(TARGET_TESTER_TARGET_BINARY_NOLFS) $(TARGET_TESTER_BINARIES_TARGET_DIR)

$(PKG_FINISH)
