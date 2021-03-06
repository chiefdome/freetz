NTFS_VERSION:=1.0
NTFS_SOURCE:=ntfs-3g-$(NTFS_VERSION).tgz
NTFS_SITE:=http://www.ntfs-3g.org/
NTFS_DIR:=$(SOURCE_DIR)/ntfs-3g-$(NTFS_VERSION)
NTFS_MAKE_DIR:=$(MAKE_DIR)/ntfs
NTFS_TARGET_DIR:=$(PACKAGES_DIR)/ntfs-$(NTFS_VERSION)/root/usr/bin
NTFS_TARGET_BINARY:=ntfs-3g
NTFS_PKG_SOURCE:=ntfs-$(NTFS_VERSION)-dsmod.tar.bz2
NTFS_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

$(DL_DIR)/$(NTFS_SOURCE):
	wget -P $(DL_DIR) $(NTFS_SITE)/$(NTFS_SOURCE)

$(DL_DIR)/$(NTFS_PKG_SOURCE):
	@wget -P $(DL_DIR) $(NTFS_PKG_SITE)/$(NTFS_PKG_SOURCE)

$(NTFS_DIR)/.unpacked: $(DL_DIR)/$(NTFS_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(NTFS_SOURCE)
	for i in $(NTFS_MAKE_DIR)/patches/*.patch; do \
		patch -d $(NTFS_DIR) -p0 < $$i; \
	done
	touch $@

$(NTFS_DIR)/.configured: fuse $(NTFS_DIR)/.unpacked
	(cd $(NTFS_DIR); rm -f config.cache; \
		touch configure.in ; \
		touch aclocal.m4 ; \
		touch Makefile.in ; \
		touch include/config.h.in ; \
		touch configure ; \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
		./configure \
			--target=$(GNU_TARGET_NAME) \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--program-prefix="" \
			--program-suffix="" \
			--prefix=/usr \
			--exec-prefix=/usr \
			--bindir=/usr/bin \
			--datadir=/usr/share \
			--includedir=/usr/include \
			--infodir=/usr/share/info \
			--libdir=/usr/lib \
			--libexecdir=/usr/lib \
			--localstatedir=/var \
			--mandir=/usr/share/man \
			--sbindir=/usr/sbin \
			--sysconfdir=/etc \
			$(DISABLE_LARGEFILE) \
			$(DISABLE_NLS) \
			--enable-shared \
			--enable-static \
			--disable-rpath \
			--enable-kernel-module \
			--enable-lib \
			--enable-util \
			--disable-example \
			--disable-auto-modprobe \
			--with-kernel="$(shell pwd)/../$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/" \
			--disable-mtab \
	);
	
$(NTFS_DIR)/src/.libs/$(NTFS_TARGET_BINARY): $(NTFS_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		-C $(NTFS_DIR) all

$(PACKAGES_DIR)/.ntfs-$(NTFS_VERSION): $(DL_DIR)/$(NTFS_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(NTFS_PKG_SOURCE)
	@touch $@

ntfs: $(PACKAGES_DIR)/.ntfs-$(NTFS_VERSION)

ntfs-package: $(PACKAGES_DIR)/.ntfs-$(NTFS_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(NTFS_PKG_SOURCE) ntfs-$(NTFS_VERSION)

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libntfs-3g.so: $(NTFS_DIR)/src/.libs/$(NTFS_TARGET_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(NTFS_DIR)/libntfs-3g \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

ntfs-precompiled: ntfs $(NTFS_DIR)/src/.libs/$(NTFS_TARGET_BINARY) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libntfs-3g.so
	$(TARGET_STRIP) $(NTFS_DIR)/src/.libs/$(NTFS_TARGET_BINARY)
	cp $(NTFS_DIR)/src/.libs/$(NTFS_TARGET_BINARY) $(NTFS_TARGET_DIR)/
ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
			cp -a $(TARGET_MAKE_PATH)/../usr/lib/libntfs*.so* root/usr/lib/
else
			$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libntfs*.so*
			cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libntfs*.so* root/usr/lib/
endif

ntfs-source: $(NTFS_DIR)/.unpacked $(PACKAGES_DIR)/.ntfs-$(NTFS_VERSION)

ntfs-clean:
	-$(MAKE) -C $(NTFS_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(NTFS_PKG_SOURCE)

ntfs-dirclean:
	rm -rf $(NTFS_DIR)
	rm -rf $(PACKAGES_DIR)/ntfs-$(NTFS_VERSION)
	rm -f $(PACKAGES_DIR)/.ntfs-$(NTFS_VERSION)

ntfs-list:
ifeq ($(strip $(DS_PACKAGE_NTFS)),y)
	@echo "S40ntfs-$(NTFS_VERSION)" >> .static
else
	@echo "S40ntfs-$(NTFS_VERSION)" >> .dynamic
endif