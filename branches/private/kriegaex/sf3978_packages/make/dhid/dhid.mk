$(call PKG_INIT_BIN, 5.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=47d1a54a87653aef424ef0f8ab9a0b20
$(PKG)_SITE:=ftp://ftp.dhis.org/pub/dhis/
$(PKG)_BINARIES:=$(pkg) genkeys
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := gmp
$(PKG)_LIBS := -lgmp

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(DHID_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include -DQRC=1" \
		LIBS="$(DHID_LIBS)" \
		LFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(DHID_DIR) clean
	$(RM) $(DHID_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DHID_BINARIES_TARGET_DIR)

$(PKG_FINISH)
