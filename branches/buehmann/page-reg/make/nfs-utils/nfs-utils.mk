$(call PKG_INIT_BIN,1.2.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=@SF/nfs
$(PKG)_EXPORTFS_BINARY:=$($(PKG)_DIR)/utils/exportfs/exportfs
$(PKG)_EXPORTFS_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/exportfs
$(PKG)_MOUNTD_BINARY:=$($(PKG)_DIR)/utils/mountd/mountd
$(PKG)_MOUNTD_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/mountd
$(PKG)_NFSD_BINARY:=$($(PKG)_DIR)/utils/nfsd/nfsd
$(PKG)_NFSD_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/nfsd
$(PKG)_SHOWMOUNT_BINARY:=$($(PKG)_DIR)/utils/showmount/showmount
$(PKG)_SHOWMOUNT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/showmount
$(PKG)_SOURCE_MD5:=779cf81044e92cb51ad590960e7b3671

$(PKG)_DEPENDS_ON := tcp_wrappers

$(PKG)_CONFIGURE_ENV += ac_cv_type_getgroups=gid_t
$(PKG)_CONFIGURE_ENV += ac_cv_func_getgroups_works=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_stat_empty_string_bug=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_lstat_empty_string_bug=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_lstat_dereferences_slashed_symlink=no

$(PKG)_CONFIGURE_OPTIONS += --disable-nfsv4
$(PKG)_CONFIGURE_OPTIONS += --disable-mount
$(PKG)_CONFIGURE_OPTIONS += --disable-gss
$(PKG)_CONFIGURE_OPTIONS += --disable-uuid

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_EXPORTFS_BINARY) $($(PKG)_MOUNTD_BINARY) \
		$($(PKG)_NFSD_BINARY) $($(PKG)_SHOWMOUNT_BINARY)) : \
		$($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NFS_UTILS_DIR) \
		OPT="$(TARGET_CFLAGS)" \
		CC="$(TARGET_CC)" \
		all

$($(PKG)_EXPORTFS_TARGET_BINARY): $($(PKG)_EXPORTFS_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MOUNTD_TARGET_BINARY):	$($(PKG)_MOUNTD_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_NFSD_TARGET_BINARY): $($(PKG)_NFSD_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SHOWMOUNT_TARGET_BINARY): $($(PKG)_SHOWMOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_EXPORTFS_TARGET_BINARY) $($(PKG)_MOUNTD_TARGET_BINARY) \
			$($(PKG)_NFSD_TARGET_BINARY) $($(PKG)_SHOWMOUNT_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NFS_UTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(NFS_UTILS_EXPORTFS_TARGET_BINARY) \
		$(NFS_UTILS_MOUNTD_TARGET_BINARY) \
		$(NFS_UTILS_NFSD_TARGET_BINARY) \
		$(NFS_UTILS_SHOWMOUNT_TARGET_BINARY)

$(PKG_FINISH)
