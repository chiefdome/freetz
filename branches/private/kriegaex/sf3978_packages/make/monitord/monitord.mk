$(call PKG_INIT_BIN, 0.4.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://bsd.cenkes.org/myports
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_SOURCE_MD5:=3cc368f2f000f445df0ccfe051ac2564

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MONITORD_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MONITORD_DIR) clean
	$(RM) $(MONITORD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(MONITORD_TARGET_BINARY)

$(PKG_FINISH)
