$(call PKG_INIT_BIN, src-1.1.3)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=0ccd96cc01351c0562f1e4b94aaa2790
$(PKG)_SITE:=http://fgouget.free.fr/$(pkg)/
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)_$($(PKG)_VERSION)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(BING_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BING_DIR) clean
	$(RM) $(BING_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BING_BINARIES_TARGET_DIR)

$(PKG_FINISH)
