$(call PKG_INIT_BIN, 1.5012)
$(PKG)_SOURCE:=ntfs-3g-$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://www.ntfs-3g.org
$(PKG)_DIR:=$(SOURCE_DIR)/ntfs-3g-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/ntfs-3g
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ntfs-3g

$(PKG)_DEPENDS_ON := fuse

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-library
$(PKG)_CONFIGURE_OPTIONS += --with-fuse=internal


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(NTFS_DIR) all \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(NTFS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(NTFS_TARGET_BINARY)

$(PKG_FINISH)
