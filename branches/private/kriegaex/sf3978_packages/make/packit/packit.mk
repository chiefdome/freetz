$(call PKG_INIT_BIN, 1.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=270594ff97f6c203131136208bb4d2ca
$(PKG)_SITE:=http://tools.l0t3k.net/PacketGenerator
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON := libpcap libnet

$(PKG)_CONFIGURE_OPTIONS += --with-libnet-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libnet/"
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libpcap/"
$(PKG)_CONFIGURE_OPTIONS += --with-libnet-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/"
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(PACKIT_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PACKIT_DIR) clean
	$(RM) $(PACKIT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(PACKIT_TARGET_BINARY)

$(PKG_FINISH)
