JAMVM_VERSION:=1.4.5
JAMVM_SOURCE:=jamvm-$(JAMVM_VERSION).tar.gz
JAMVM_SITE:=http://mesh.dl.sourceforge.net/sourceforge/jamvm
JAMVM_DIR:=$(SOURCE_DIR)/jamvm-$(JAMVM_VERSION)
JAMVM_MAKE_DIR:=$(MAKE_DIR)/jamvm
JAMVM_TARGET_DIR:=$(PACKAGES_DIR)/jamvm-$(JAMVM_VERSION)/root/usr/bin
JAMVM_TARGET_BINARY:=jamvm
JAMVM_PKG_VERSION:=0.1
JAMVM_PKG_SOURCE:=jamvm-$(JAMVM_VERSION)-dsmod-$(JAMVM_PKG_VERSION).tar.bz2
JAMVM_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
JAMVM_PKG_SOURCE:=jamvm-$(JAMVM_VERSION)-dsmod-binary-only.tar.bz2



$(DL_DIR)/$(JAMVM_SOURCE):
	wget -P $(DL_DIR) $(JAMVM_SITE)/$(JAMVM_SOURCE)

$(DL_DIR)/$(JAMVM_PKG_SOURCE):
	@wget -P $(DL_DIR) $(JAMVM_PKG_SITE)/$(JAMVM_PKG_SOURCE)

$(JAMVM_DIR)/.unpacked: $(DL_DIR)/$(JAMVM_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(JAMVM_SOURCE)
	for i in $(JAMVM_MAKE_DIR)/patches/*.patch; do \
		patch -d $(JAMVM_DIR) -p0 < $$i; \
	done
	touch $@

$(JAMVM_DIR)/.configured: $(JAMVM_DIR)/.unpacked \
			  $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.so \
			  $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/classpath/libjavalang.so
	( cd $(JAMVM_DIR); rm -f config.status; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
		./configure \
		--target="$(GNU_TARGET_NAME)" \
		--host="$(GNU_TARGET_NAME)" \
		--build="$(GNU_HOST_NAME)" \
		--enable-ffi \
		--disable-int-threading \
		--with-classpath-install-dir="/usr/lib/classpath" \
	);
	touch $@
	

$(JAMVM_DIR)/$(JAMVM_TARGET_BINARY): $(JAMVM_DIR)/.configured
	( cd $(JAMVM_DIR)/src; \
		make $(TARGET_CONFIGURE_OPTS) \
	);

$(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION): $(DL_DIR)/$(JAMVM_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(JAMVM_PKG_SOURCE)
	@touch $@

jamvm: $(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION)

jamvm-package: $(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE)  --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(JAMVM_PKG_SOURCE) jamvm-$(JAMVM_VERSION)

jamvm-precompiled: $(JAMVM_DIR)/$(JAMVM_TARGET_BINARY) jamvm
	$(TARGET_STRIP) $(JAMVM_DIR)/src/$(JAMVM_TARGET_BINARY)
	cp $(JAMVM_DIR)/src/$(JAMVM_TARGET_BINARY) $(JAMVM_TARGET_DIR)/
	$(TARGET_STRIP) $(JAMVM_DIR)/src/.libs/libjvm*.so*
	cp $(JAMVM_DIR)/src/.libs/libjvm*.so* $(JAMVM_TARGET_DIR)/../lib

jamvm-source: $(JAMVM_DIR)/.unpacked $(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION)

jamvm-clean:
	-$(MAKE) -C $(JAMVM_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(JAMVM_PKG_SOURCE)

jamvm-dirclean:
	rm -rf $(JAMVM_DIR)
	rm -rf $(PACKAGES_DIR)/jamvm-$(JAMVM_VERSION)
	rm -f $(PACKAGES_DIR)/.jamvm-$(JAMVM_VERSION)

jamvm-list:
ifeq ($(strip $(DS_PACKAGE_JAMVM)),y)
	@echo "S40jamvm-$(JAMVM_VERSION)" >> .static
else
	@echo "S40jamvm-$(JAMVM_VERSION)" >> .dynamic
endif
