$(call PKG_INIT_BIN, 0.62)
$(PKG)_SOURCE:=$(pkg).tar.gz
$(PKG)_SOURCE_MD5:=28c78bac648971724c46f1a921154c4f
$(PKG)_SITE:=http://www.boutell.com/$(pkg)/http
$(PKG)_BINARIES:=$(pkg)
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RINETD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RINETD_DIR) clean
	$(RM) $(RINETD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(RINETD_BINARIES_TARGET_DIR)

$(PKG_FINISH)
