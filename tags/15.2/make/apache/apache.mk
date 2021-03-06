APACHE_VERSION:=1.3.37
APACHE_SOURCE:=apache_$(APACHE_VERSION).tar.gz
APACHE_SITE:=http://ftp.uni-erlangen.de/pub/mirrors/apache/httpd
APACHE_MAKE_DIR:=$(MAKE_DIR)/apache
APACHE_DIR:=$(SOURCE_DIR)/apache_$(APACHE_VERSION)
APACHE_BINARY:=$(APACHE_DIR)/src/apache
APACHE_TARGET_DIR:=$(PACKAGES_DIR)/apache-$(APACHE_VERSION)
APACHE_TARGET_BINARY:=$(APACHE_TARGET_DIR)/apache
APACHE_PKG_VERSION:=0.1
APACHE_PKG_SOURCE:=apache-$(APACHE_VERSION)-dsmod-$(APACHE_PKG_VERSION).tar.bz2
APACHE_PKG_SITE:=http://dsmod.magenbrot.net

APACHE_DS_CONFIG_FILE:=$(APACHE_MAKE_DIR)/.ds_config
APACHE_DS_CONFIG_TEMP:=$(APACHE_MAKE_DIR)/.ds_config.temp

$(DL_DIR)/$(APACHE_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(APACHE_SITE)/$(APACHE_SOURCE)

$(DL_DIR)/$(APACHE_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(APACHE_PKG_SOURCE) $(APACHE_PKG_SITE)

$(APACHE_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_APACHE_STATIC=$(if $(DS_APACHE_STATIC),y,n)" > $(APACHE_DS_CONFIG_TEMP)
	@diff -q $(APACHE_DS_CONFIG_TEMP) $(APACHE_DS_CONFIG_FILE) || \
		cp $(APACHE_DS_CONFIG_TEMP) $(APACHE_DS_CONFIG_FILE)
	@rm -f $(APACHE_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(APACHE_DIR)/.unpacked: $(DL_DIR)/$(APACHE_SOURCE) $(APACHE_DS_CONFIG_FILE)
	rm -rf $(APACHE_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(APACHE_SOURCE)
	for i in $(APACHE_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(APACHE_DIR) $$i; \
	done
	touch $@

$(APACHE_DIR)/.configured: $(APACHE_DIR)/.unpacked
	( cd $(APACHE_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(if $(DS_APACHE_STATIC),-static)" \
		./configure \
		--target=apache \
		--prefix=./apache-1.3.37/ \
		--enable-module=rewrite=yes \
		--enable-module=speling=yes \
	);
	touch $@

$(APACHE_BINARY): $(APACHE_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(APACHE_DIR)

$(PACKAGES_DIR)/.apache-$(APACHE_VERSION): $(DL_DIR)/$(APACHE_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(APACHE_PKG_SOURCE)
	@touch $@

$(APACHE_TARGET_BINARY): $(APACHE_BINARY)
	$(INSTALL_BINARY_STRIP)

apache: $(PACKAGES_DIR)/.apache-$(APACHE_VERSION)

apache-package: $(PACKAGES_DIR)/.apache-$(APACHE_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(APACHE_PKG_SOURCE) apache-$(APACHE_VERSION)

apache-precompiled: uclibc apache $(APACHE_TARGET_BINARY)

apache-source: $(APACHE_DIR)/.unpacked $(PACKAGES_DIR)/.apache-$(APACHE_VERSION)

apache-clean:
	-$(MAKE) -C $(APACHE_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(APACHE_PKG_SOURCE)
	rm -f $(APACHE_DS_CONFIG_FILE)

apache-dirclean:
	rm -rf $(APACHE_DIR)
	rm -f $(PACKAGES_BUILD_DIR)/$(APACHE_PKG_SOURCE)
	rm -rf $(PACKAGES_DIR)/apache-$(APACHE_VERSION)
	rm -f $(PACKAGES_DIR)/.apache-$(APACHE_VERSION)
	rm -f $(PACKAGES_DIR)/.php-$(PHP_VERSION)
	rm -f $(APACHE_DS_CONFIG_FILE)

apache-uninstall:
	rm -f $(APACHE_TARGET_BINARY)

apache-list:
#ifeq ($(strip $(DS_PACKAGE_APACHE)),y)
#	@echo "S99apache-$(APACHE_VERSION)" >> .static
#else
#	@echo "S99apache-$(APACHE_VERSION)" >> .dynamic
#endif
