$(call PKG_INIT_BIN, 0.9.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=6714e3ddad2711eb4fcfa24a257f0ee8
$(PKG)_SITE:=https://$(pkg)-tool.googlecode.com/files/
$(PKG)_BINARIES:=bw
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(BANDWIDTH_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BANDWIDTH_DIR) clean
	$(RM) $(BANDWIDTH_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BANDWIDTH_BINARIES_TARGET_DIR)

$(PKG_FINISH)
