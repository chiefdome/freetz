$(call PKG_INIT_BIN, 1.5.1a)
$(PKG)_SOURCE:=$(pkg)_1.5.1.orig.tar.gz
$(PKG)_SOURCE_MD5:=85bb085077c380b82a6ff73e0de0c154
$(PKG)_SITE:=http://ftp.debian.org/debian/pool/main/n/$(pkg)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(NBTSCAN_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NBTSCAN_DIR) clean
	$(RM) $(NBTSCAN_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NBTSCAN_BINARIES_TARGET_DIR)

$(PKG_FINISH)
