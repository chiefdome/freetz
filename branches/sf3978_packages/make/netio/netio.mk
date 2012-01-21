$(call PKG_INIT_BIN, 1.31)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=0523b25154fb4d987bbaf5b3b3a0751d
$(PKG)_SITE:=http://freetz.org/raw-attachment/ticket/1244/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(NETIO_DIR) \
		  CC="$(TARGET_CC)" \
		  CFLAGS="$(TARGET_CFLAGS) -DUNIX"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NETIO_DIR) clean
	$(RM) $(NETIO_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NETIO_BINARIES_TARGET_DIR)

$(PKG_FINISH)
