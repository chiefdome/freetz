$(call PKG_INIT_BIN, 0.0.8-dev-ssl)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=be2d43965915c63af70410f6380c5576
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_BINARIES:=$(pkg) $(pkg)d nsocks
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := openssl
$(PKG)_LIBS := -lssl -lcrypto -lpthread -ldl

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/var/tmp/flash/mod

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(SSOCKS_DIR) \
		  LIBS="$(SSOCKS_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(SSOCKS_DIR) clean
	$(RM) $(SSOCKS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SSOCKS_BINARIES_TARGET_DIR)

$(PKG_FINISH)
