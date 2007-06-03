UCLIBCXX_VERSION:=0.2.1
UCLIBCXX_SOURCE:=uClibc++-$(UCLIBCXX_VERSION).tar.bz2
UCLIBCXX_SITE:=http://cxx.uclibc.org/src/
UCLIBCXX_DIR:=$(SOURCE_DIR)/uClibc++-$(UCLIBCXX_VERSION)
UCLIBCXX_MAKE_DIR:=$(MAKE_DIR)/libs


$(DL_DIR)/$(UCLIBCXX_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(UCLIBCXX_SITE)/$(UCLIBCXX_SOURCE)

$(UCLIBCXX_DIR)/.unpacked: $(DL_DIR)/$(UCLIBCXX_SOURCE)
	tar -C $(SOURCE_DIR) -xvjf $(DL_DIR)/$(UCLIBCXX_SOURCE)
	touch $@

$(UCLIBCXX_DIR)/.configured: $(UCLIBCXX_DIR)/.unpacked
	cp $(UCLIBCXX_MAKE_DIR)/Config.uclibc++ $(UCLIBCXX_DIR)/.config
ifeq ($(DS_TARGET_LFS),y)
	$(SED) -i -e 's,^.*UCLIBCXX_HAS_LFS.*,UCLIBCXX_HAS_LFS=y,g' $(UCLIBCXX_DIR)/.config
else
	$(SED) -i -e 's,^.*UCLIBCXX_HAS_LFS.*,UCLIBCXX_HAS_LFS=n,g' $(UCLIBCXX_DIR)/.config
endif
	touch $@

$(UCLIBCXX_DIR)/.compiled: $(UCLIBCXX_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(UCLIBCXX_DIR) \
		CC="$(TARGET_CC)" \
		ARCH_CFLAGS="$(TARGET_CFLAGS)" \
		CROSS="$(TARGET_CROSS)" \
		all
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libuClibc++.so: $(UCLIBCXX_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(UCLIBCXX_DIR) \
		ARCH_CFLAGS="$(TARGET_CFLAGS)" \
		CROSS="$(TARGET_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	mv $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/g++-uc \
	   $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-g++-uc
	ln -sf $(REAL_GNU_TARGET_NAME)-g++-uc $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-g++-uc
	touch -c $@

uclibcxx: $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libuClibc++.so

uclibcxx-precompiled: uclibc uclibcxx
	chmod 755 $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libuClibc++*.so*
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libuClibc++*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libuClibc++*.so* root/lib/

uclibcxx-source: $(UCLIBCXX_DIR)/.unpacked

uclibcxx-clean:
	-$(MAKE) -C $(UCLIBCXX_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libuClibc++* 
	rm -rf root/lib/libuClibc++*.so* 

uclibcxx-dirclean:
	rm -rf $(UCLIBCXX_DIR)
