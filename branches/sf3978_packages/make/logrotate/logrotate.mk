$(call PKG_INIT_BIN, 3.7.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://fedorahosted.org/releases/l/o/$(pkg)/
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_SOURCE_MD5:=b3589bea6d8d5afc8a84134fddaae973

$(PKG)_DEPENDS_ON := popt
$(PKG)_LIBS := -lpopt

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(LOGROTATE_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LIBS="$(LOGROTATE_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LOGROTATE_DIR) clean
	$(RM) $(LOGROTATE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(LOGROTATE_TARGET_BINARY)

$(PKG_FINISH)
