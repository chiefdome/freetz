$(call PKG_INIT_BIN,1.4.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c9e8aeb15daeba4b6283b40bb640e908
$(PKG)_SITE:=http://mirrors.zerg.biz/nongnu/davfs2
$(PKG)_STARTLEVEL=50
$(PKG)_MOUNT_BINARY:=$($(PKG)_DIR)/src/mount.davfs
$(PKG)_MOUNT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mount.davfs
$(PKG)_UMOUNT_BINARY:=$($(PKG)_DIR)/src/umount.davfs
$(PKG)_UMOUNT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/umount.davfs

$(PKG)_DEPENDS_ON := neon fuse
$(PKG)_LIBS := \$$(NEON_LIBS)

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
$(PKG)_LIBS += -liconv
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DAVFS2_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DAVFS2_WITH_ZLIB

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_MOUNT_BINARY) $($(PKG)_UMOUNT_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DAVFS2_DIR) \
		LIBS="$(DAVFS2_LIBS)"

$($(PKG)_MOUNT_TARGET_BINARY): $($(PKG)_MOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_UMOUNT_TARGET_BINARY): $($(PKG)_UMOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): $($(PKG)_TARGET_DIR)/.exclude

$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	[ "$(FREETZ_PACKAGE_DAVFS2_REMOVE_WEBIF)" == "y" ] \
		&& echo "etc/init.d/rc.davfs2" >> $@ \
		&& echo "etc/default.davfs2/" >> $@ \
		&& echo "usr/lib/cgi-bin/davfs2.cgi" >> $@; \
	touch $@

$(pkg)-precompiled: $($(PKG)_MOUNT_TARGET_BINARY) $($(PKG)_UMOUNT_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DAVFS2_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DAVFS2_MOUNT_TARGET_BINARY) $(DAVFS2_UMOUNT_TARGET_BINARY)

$(PKG_FINISH)
