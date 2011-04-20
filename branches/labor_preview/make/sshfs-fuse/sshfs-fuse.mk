$(call PKG_INIT_BIN, 2.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=26e9206eb5169e87e6f95f54bc005a4f
$(PKG)_SITE:=@SF/fuse
$(PKG)_BINARY:=$($(PKG)_DIR)/sshfs
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sshfs

$(PKG)_DEPENDS_ON := fuse glib2

$(PKG)_CONFIGURE_OPTIONS += --disable-sshnodelay

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) : $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SSHFS_FUSE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SSHFS_FUSE_DIR) clean
	$(RM) $(SSHFS_FUSE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SSHFS_FUSE_TARGET_BINARY)

$(PKG_FINISH)
