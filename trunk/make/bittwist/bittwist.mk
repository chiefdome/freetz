$(call PKG_INIT_BIN, 1.1)
$(PKG)_SOURCE:=$(pkg)-linux-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=d79f0181c5b1f14707542674fb747fb7
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_BINARIES:=bittwist bittwiste bittwistb
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := libpcap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BITTWIST_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(MAKE) -C $(BITTWIST_DIR) clean
	$(RM) $(BITTWIST_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BITTWIST_BINARIES_TARGET_DIR)

$(PKG_FINISH)
