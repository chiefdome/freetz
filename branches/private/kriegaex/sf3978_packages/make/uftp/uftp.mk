$(call PKG_INIT_BIN, 3.5.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar
$(PKG)_SOURCE_MD5:=dcf922327a7fc76159d11226b9bc0579
$(PKG)_SITE:=https://www.tcnj.edu/~bush/downloads
$(PKG)_BINARIES:=$(pkg) $(pkg)d $(pkg)proxyd $(pkg)_keymgt
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
 
$(PKG)_DEPENDS_ON := openssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(UFTP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(UFTP_DIR) clean
	$(RM) $(UFTP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UFTP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
