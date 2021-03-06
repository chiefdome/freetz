CLASSPATH_VERSION:=0.93
CLASSPATH_SOURCE:=classpath-$(CLASSPATH_VERSION).tar.gz
CLASSPATH_SITE:=ftp://ftp.gnu.org/gnu/classpath
CLASSPATH_DIR:=$(SOURCE_DIR)/classpath-$(CLASSPATH_VERSION)
CLASSPATH_MAKE_DIR:=$(MAKE_DIR)/classpath
CLASSPATH_TARGET_DIR:=$(PACKAGES_DIR)/classpath-$(CLASSPATH_VERSION)/root/usr/lib/classpath
CLASSPATH_TARGET_BINARY:=mini.jar #glibj.zip
CLASSPATH_PKG_VERSION:=0.1
CLASSPATH_PKG_SOURCE:=CLASSPATH-$(CLASSPATH_VERSION)-dsmod-$(CLASSPATH_PKG_VERSION).tar.bz2
CLASSPATH_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
CLASSPATH_PKG_SOURCE:=classpath-$(CLASSPATH_VERSION)-dsmod.tar.bz2



$(DL_DIR)/$(CLASSPATH_SOURCE):
	wget -P $(DL_DIR) $(CLASSPATH_SITE)/$(CLASSPATH_SOURCE)

$(DL_DIR)/$(CLASSPATH_PKG_SOURCE):
	@wget -P $(DL_DIR) $(CLASSPATH_PKG_SITE)/$(CLASSPATH_PKG_SOURCE)

$(CLASSPATH_DIR)/.unpacked: $(DL_DIR)/$(CLASSPATH_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(CLASSPATH_SOURCE)
#	for i in $(CLASSPATH_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(CLASSPATH_DIR) -p1 < $$i; \
#	done
	touch $@

$(CLASSPATH_DIR)/.configured: $(CLASSPATH_DIR)/.unpacked
	( cd $(CLASSPATH_DIR); rm -f config.status; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
		./configure \
		--target="$(GNU_TARGET_NAME)" \
		--host="$(GNU_TARGET_NAME)" \
		--build="$(GNU_HOST_NAME)" \
		--prefix="/usr" \
		--disable-gtk-peer \
		--disable-qt-peer \
		--disable-gconf-peer \
		--without-libiconv-prefix \
		--disable-plugin \
		--with-jikes \
		--disable-Werror \
	);
	touch $@

$(CLASSPATH_DIR)/$(CLASSPATH_TARGET_BINARY): $(CLASSPATH_DIR)/.configured
	( cd $(CLASSPATH_DIR); \
		make $(TARGET_CONFIGURE_OPTS); \
	);
	cp $(CLASSPATH_MAKE_DIR)/mini.classlist $(CLASSPATH_DIR)/lib;
	( cd $(CLASSPATH_DIR)/lib; fastjar -Mcf mini.jar -@ < mini.classlist );

$(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION): $(DL_DIR)/$(CLASSPATH_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CLASSPATH_PKG_SOURCE)
	@touch $@

classpath: $(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION)

classpath-package: $(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(CLASSPATH_PKG_SOURCE) classpath-$(CLASSPATH_VERSION)

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.so: $(CLASSPATH_DIR)/$(CLASSPATH_TARGET_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(CLASSPATH_DIR)/native/jni \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

classpath-precompiled: $(CLASSPATH_DIR)/$(CLASSPATH_TARGET_BINARY) $(CLASSPATH_DIR)/.installed classpath
	cp $(CLASSPATH_DIR)/lib/$(CLASSPATH_TARGET_BINARY) $(CLASSPATH_TARGET_DIR)/
	
ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
$(CLASSPATH_DIR)/.installed:
	mkdir -p root/usr/lib/classpath
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/classpath/lib*.so* root/usr/lib/classpath
	( cd $(CLASSPATH_DIR)/lib; cp mini.jar $(CLASSPATH_TARGET_DIR);		
	touch $@
else
$(CLASSPATH_DIR)/.installed: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.so
	mkdir -p root/usr/lib/classpath
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/lib*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/lib*.so* root/usr/lib/classpath
	touch $@
endif


classpath-source: $(CLASSPATH_DIR)/.unpacked $(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION)

classpath-clean:
	-$(MAKE) -C $(CLASSPATH_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(CLASSPATH_PKG_SOURCE)

classpath-dirclean:
	rm -rf $(CLASSPATH_DIR)
	rm -rf $(PACKAGES_DIR)/classpath-$(CLASSPATH_VERSION)
	rm -f $(PACKAGES_DIR)/.classpath-$(CLASSPATH_VERSION)

classpath-list:
ifeq ($(strip $(DS_PACKAGE_CLASSPATH)),y)
	@echo "S40classpath-$(CLASSPATH_VERSION)" >> .static
else
	@echo "S40classpath-$(CLASSPATH_VERSION)" >> .dynamic
endif
