$(call PKG_INIT_BIN, 1.2)
$(PKG)_SOURCE:=portsentry-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://heanet.dl.sourceforge.net/project/sentrytools/portsentry%201.x/portsentry-1.2
$(PKG)_BINARY:=$(SOURCE_DIR)/portsentry_beta/portsentry
PORTSENTRY_DIR:=$(SOURCE_DIR)/portsentry_beta
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/portsentry
$(PKG)_SOURCE_MD5:=3ebd3618ba9abfea2525e236bd44cebd

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(PORTSENTRY_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PORTSENTRY_DIR) clean
	$(RM) $(PORTSENTRY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(PORTSENTRY_TARGET_BINARY)

$(PKG_FINISH)
