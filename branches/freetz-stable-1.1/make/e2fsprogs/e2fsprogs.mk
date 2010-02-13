$(call PKG_INIT_BIN, 1.41.3)
$(PKG)_SOURCE:=e2fsprogs-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/e2fsprogs
$(PKG)_DIR:=$(SOURCE_DIR)/e2fsprogs-$($(PKG)_VERSION)
$(PKG)_E2FSCK_BINARY:=$(E2FSPROGS_DIR)/e2fsck/e2fsck
$(PKG)_E2FSCK_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/e2fsck
$(PKG)_MKE2FS_BINARY:=$(E2FSPROGS_DIR)/misc/mke2fs
$(PKG)_MKE2FS_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/mke2fs
$(PKG)_TUNE2FS_BINARY:=$(E2FSPROGS_DIR)/misc/tune2fs
$(PKG)_TUNE2FS_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tune2fs
$(PKG)_BLKID_BINARY:=$(E2FSPROGS_DIR)/misc/blkid
$(PKG)_BLKID_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/blkid
$(PKG)_BLKID_LIB_BINARY:=$($(PKG)_DIR)/lib/blkid/libblkid.a
$(PKG)_BLKID_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libblkid.a
$(PKG)_UUID_LIB_BINARY:=$($(PKG)_DIR)/lib/uuid/libuuid.a
$(PKG)_UUID_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libuuid.a


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_E2FSCK_BINARY) \
	$($(PKG)_TUNE2FS_BINARY) \
	$($(PKG)_MKE2FS_BINARY) \
	$($(PKG)_BLKID_LIB_BINARY) \
	$($(PKG)_UUID_LIB_BINARY) : $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(E2FSPROGS_DIR) \
		all

$($(PKG)_E2FSCK_TARGET_BINARY): $($(PKG)_E2FSCK_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MKE2FS_TARGET_BINARY): $($(PKG)_MKE2FS_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TUNE2FS_TARGET_BINARY): $($(PKG)_TUNE2FS_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_BLKID_TARGET_BINARY): $($(PKG)_BLKID_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_BLKID_LIB_STAGING_BINARY): $($(PKG)_BLKID_LIB_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(E2FSPROGS_DIR)/lib/blkid \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/blkid.pc

$($(PKG)_UUID_LIB_STAGING_BINARY): $($(PKG)_UUID_LIB_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(E2FSPROGS_DIR)/lib/uuid \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/uuid.pc

$(pkg):

$(pkg)-precompiled: $($(PKG)_E2FSCK_TARGET_BINARY) \
			$($(PKG)_MKE2FS_TARGET_BINARY) \
			$($(PKG)_TUNE2FS_TARGET_BINARY) \
			$($(PKG)_BLKID_TARGET_BINARY) \
			$($(PKG)_BLKID_LIB_STAGING_BINARY) \
			$($(PKG)_UUID_LIB_STAGING_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(E2FSPROGS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(E2FSPROGS_E2FSCK_TARGET_BINARY) \
			$(E2FSPROGS_MKE2FS_TARGET_BINARY) \
			$(E2FSPROGS_TUNE2FS_TARGET_BINARY) \
			$(E2FSPROGS_BLKID_TARGET_BINARY) \
			$(E2FSPROGS_BLKID_LIB_STAGING_BINARY) \
			$(E2FSPROGS_UUID_LIB_STAGING_BINARY)

$(PKG_FINISH)
