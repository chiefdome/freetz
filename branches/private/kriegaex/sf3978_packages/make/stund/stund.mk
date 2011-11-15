$(call PKG_INIT_BIN, 0.96)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION)_Aug13.tgz
$(PKG)_SOURCE_MD5:=3273abb1a6f299f4e611b658304faefa
$(PKG)_SITE:=http://downloads.sourceforge.net/project/stun/stun/0.96
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)
$(PKG)_BINARIES:=server client
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := $(STDCXXLIB)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(STUND_DIR) \
		CXX="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS) -fno-builtin -fno-rtti -nostdinc++" \
		LDFLAGS="$(TARGET_LDFLAGS) -nodefaultlibs" \
		all

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(STUND_DIR) clean
	 $(RM) $(STUND_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(STUND_TARGET_BINARY)
	$(RM) $(STUND_BINARIES_TARGET_DIR)

$(PKG_FINISH)
