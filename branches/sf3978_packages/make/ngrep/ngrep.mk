$(call PKG_INIT_BIN, 1.45)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=bc8150331601f3b869549c94866b4f1c
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := pcre libpcap
$(PKG)_LDFLAGS := -lpcre

$(PKG)_CONFIGURE_OPTIONS += --with-pcap-includes=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
$(PKG)_CONFIGURE_OPTIONS += --enable-pcre
$(PKG)_CONFIGURE_OPTIONS += --disable-dropprivs

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(NGREP_DIR) \
		LDFLAGS="$(TARGET_LDFLAGS) $(NGREP_LDFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(NGREP_DIR) clean
	$(RM) $(NGREP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NGREP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
