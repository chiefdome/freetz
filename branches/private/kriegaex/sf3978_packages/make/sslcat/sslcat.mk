$(call PKG_INIT_BIN, 0.1)
$(PKG)_SOURCE:=$(pkg).tgz
$(PKG)_SOURCE_MD5:=27a88e2143cbfe216e13e9493bacd32e
$(PKG)_SITE:=http://www.bindshell.net/tools/$(pkg)/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_LIBS := -lssl -lcrypto

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(SSLCAT_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LIBS="$(SSLCAT_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SSLCAT_DIR) clean
	$(RM) $(SSLCAT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SSLCAT_BINARIES_TARGET_DIR)

$(PKG_FINISH)
