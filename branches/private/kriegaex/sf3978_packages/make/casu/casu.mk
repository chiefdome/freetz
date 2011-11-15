$(call PKG_INIT_BIN, 3.3.3)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_SOURCE_MD5:=9e5ce4a3714c087f1780ee2bceb9dee2
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/c/$(pkg)/
$(PKG)_BINARIES:=to flon
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(CASU_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CASU_DIR) clean
	 $(RM) $(CASU_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(CASU_TARGET_BINARY)
	$(RM) $(CASU_BINARIES_TARGET_DIR)

$(PKG_FINISH)
