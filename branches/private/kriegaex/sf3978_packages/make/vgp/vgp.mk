$(call PKG_INIT_BIN, 0.2.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b8c25b5dfcb944f78bbc584be9c230c7
$(PKG)_SITE:=http://downloads.openwrt.org/sources/
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --with-key-length=256
$(PKG)_CONFIGURE_OPTIONS += --with-vgp-key=/tmp/flash/mod/vgpd.key

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(VGP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(VGP_DIR) clean
	$(RM) $(VGP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(VGP_TARGET_BINARY)

$(PKG_FINISH)
