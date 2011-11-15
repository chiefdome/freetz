$(call PKG_INIT_BIN, 0.9.7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=9bd0741bbb1f218be95c089dc06b2777
$(PKG)_SITE:=http://download.savannah.nongnu.org/releases/$(pkg)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-list-hack

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(CMDFTP_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CMDFTP_DIR) clean
	$(RM) $(CMDFTP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(CMDFTP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
