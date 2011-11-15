$(call PKG_INIT_BIN, 1.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=5711082dba1e87a3673a8f0429eb0741
$(PKG)_SITE:=http://$(pkg).sourceforge.net/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc/default.ffproxy/ffproxy
$(PKG)_CONFIGURE_OPTIONS += --datadir=/etc/default.ffproxy

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(FFPROXY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(FFPROXY_DIR) clean
	$(RM) $(FFPROXY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(FFPROXY_TARGET_BINARY)

$(PKG_FINISH)
