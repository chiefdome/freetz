$(call PKG_INIT_BIN, 0.5.7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=4f7f05e1a567812b46fa12ed0f0d2b7f
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON += tcp_wrappers
$(PKG)_CONFIGURE_OPTIONS += --enable-libwrap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(AMPLE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(AMPLE_DIR) clean
	$(RM) $(AMPLE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(AMPLE_TARGET_BINARY)

$(PKG_FINISH)
