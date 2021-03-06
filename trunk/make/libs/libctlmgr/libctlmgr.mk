$(call PKG_INIT_LIB, 0.5)

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_LIB)/$(pkg).so.$($(PKG)_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libctlmgr_WITH_STRUCT_V1
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libctlmgr_WITH_STRUCT_V2
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libctlmgr_WITH_STRUCT_V3

$(PKG)_CPPFLAGS += $(if $(FREETZ_LIB_libctlmgr_WITH_STRUCT_V1),-DD_STRUCT_V1)
$(PKG)_CPPFLAGS += $(if $(FREETZ_LIB_libctlmgr_WITH_STRUCT_V2),-DD_STRUCT_V2)
$(PKG)_CPPFLAGS += $(if $(FREETZ_LIB_libctlmgr_WITH_STRUCT_V3),-DD_STRUCT_V3)

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBCTLMGR_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="$(strip $(LIBCTLMGR_CPPFLAGS))" \
		LIB_VERSION="$(LIBCTLMGR_VERSION)" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBCTLMGR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LIBCTLMGR_DEST_LIB)/libctlmgr*.so*

$(PKG_FINISH)
