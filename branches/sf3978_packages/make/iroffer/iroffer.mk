$(call PKG_INIT_BIN, 1.4.b03-lamm.b02)
$(PKG)_SOURCE:=$(pkg)$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=760f693219d1b4613c76d2e187fc4fd3
$(PKG)_SITE:=http://downloads.sourceforge.net/project/$(pkg)-lamm/$(pkg)1.4-lamm/$(pkg)$($(PKG)_VERSION)/
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)$($(PKG)_VERSION)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(IROFFER_DIR) \
		CC="$(TARGET_CC)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(IROFFER_DIR) clean
	$(RM) $(IROFFER_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IROFFER_BINARIES_TARGET_DIR)

$(PKG_FINISH)
