$(call PKG_INIT_BIN, 0.4.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ddee95ad1d394a4751ebde24fcb36fa1
$(PKG)_SITE:=http://www.enderunix.org/$(pkg)

$(PKG)_BINARIES:=aget
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(AGET_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(AGET_DIR) clean
	$(RM) $(AGET_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(AGET_BINARIES_TARGET_DIR)

$(PKG_FINISH)
