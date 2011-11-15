$(call PKG_INIT_BIN, 0.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=e2911fa9de1b92ef50deda1489ae944d
$(PKG)_SITE:=ftp://ftp.uni-frankfurt.de/pub/Mirrors2/gentoo.org/distfiles
$(PKG)_BINARY:=$(SOURCE_DIR)/$(pkg)/$(pkg)
ARPD_DIR:=$(SOURCE_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON := libpcap libdnet libevent

$(PKG)_CONFIGURE_OPTIONS += --with-libdnet="$(TARGET_TOOLCHAIN_STAGING_DIR)/"
$(PKG)_CONFIGURE_OPTIONS += --with-libevent="$(TARGET_TOOLCHAIN_STAGING_DIR)/"
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap="$(TARGET_TOOLCHAIN_STAGING_DIR)/"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(ARPD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ARPD_DIR) clean
	$(RM) $(ARPD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(ARPD_TARGET_BINARY)

$(PKG_FINISH)
