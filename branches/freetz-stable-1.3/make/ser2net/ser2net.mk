$(call PKG_INIT_BIN, 2.7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=22977477789868923a5de09a85e847dd
$(PKG)_SITE:=@SF/ser2net
$(PKG)_BINARY:=$($(PKG)_DIR)/ser2net
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ser2net

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SER2NET_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SER2NET_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SER2NET_TARGET_BINARY)

$(PKG_FINISH)
