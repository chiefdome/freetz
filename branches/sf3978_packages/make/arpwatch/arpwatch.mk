$(call PKG_INIT_BIN, 2.1a15)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=cebfeb99c4a7c2a6cee2564770415fe7
$(PKG)_SITE:=ftp://ftp.ee.lbl.gov

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON := libpcap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ARPWATCH_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ARPWATCH_DIR) clean
	$(RM) $(ARPWATCH_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(ARPWATCH_TARGET_BINARY)

$(PKG_FINISH)
