$(call PKG_INIT_BIN, 0.3.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=b4166ecb4683806cc67cbf511a3e6279
$(PKG)_SITE:=http://downloads.sourceforge.net/project/$(pkg)/$(pkg)/$(pkg)-0.3.12/
$(PKG)_DIR:=$(SOURCE_DIR)/bacnet
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(BACNET4LINUX_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(BACNET4LINUX_DIR) clean
	$(RM) $(BACNET4LINUX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BACNET4LINUX_BINARIES_TARGET_DIR)

$(PKG_FINISH)
