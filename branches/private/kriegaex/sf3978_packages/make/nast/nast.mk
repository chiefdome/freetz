$(call PKG_INIT_BIN, 0.2.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=77cbab45f5850d6cdb7ecb10e291bfa7
$(PKG)_SITE:=http://download.berlios.de/$(pkg)/
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := libpcap libnet ncurses

$(PKG)_CONFIGURE_OPTIONS += --with-libnet-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libnet/"
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap-includes="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libpcap/"
$(PKG)_CONFIGURE_OPTIONS += --with-libnet-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/"
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/"
$(PKG)_CONFIGURE_OPTIONS += --libdir="$(TARGET_TOOLCHAIN_STAGING_DIR)/lib"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(NAST_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NAST_DIR) clean
	 $(RM) $(NAST_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NAST_TARGET_BINARY)

$(PKG_FINISH)
