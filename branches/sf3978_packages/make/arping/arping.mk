$(call PKG_INIT_BIN, 2.09)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=6f6a91c8700fcc7454b4e89480e417e3
$(PKG)_SITE:=http://www.habets.pp.se/synscan/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)

$(PKG)_DEPENDS_ON := libpcap libnet

$(PKG)_CONFIGURE_OPTIONS += --with-libnet-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libnet/"
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libpcap/"
$(PKG)_CONFIGURE_OPTIONS += --with-libnet-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/"
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ARPING_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ARPING_DIR) clean
	$(RM) $(ARPING_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(ARPING_TARGET_BINARY)

$(PKG_FINISH)
