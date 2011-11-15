$(call PKG_INIT_BIN, 0.3.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-src.tar.gz
$(PKG)_SOURCE_MD5:=1ac1e561779597577f96d21736750088
$(PKG)_SITE:=http://www.extatic.org/downloads/$(pkg)/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := openssl
$(PKG)_LIBS := -lssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(UHUB_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -I./src -DSSL_SUPPORT" \
		LDLIBS="$(UHUB_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UHUB_DIR) clean
	$(RM) $(UHUB_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UHUB_BINARIES_TARGET_DIR)

$(PKG_FINISH)
