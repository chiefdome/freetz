DNSMASQ_VERSION:=2.38
DNSMASQ_SOURCE:=dnsmasq-$(DNSMASQ_VERSION).tar.gz
DNSMASQ_SITE:=http://thekelleys.org.uk/dnsmasq
DNSMASQ_DIR:=$(SOURCE_DIR)/dnsmasq-$(DNSMASQ_VERSION)
DNSMASQ_MAKE_DIR:=$(MAKE_DIR)/dnsmasq
DNSMASQ_TARGET_DIR:=$(PACKAGES_DIR)/dnsmasq-$(DNSMASQ_VERSION)/root/usr/sbin
DNSMASQ_TARGET_BINARY:=src/dnsmasq
DNSMASQ_PKG_VERSION:=0.5
DNSMASQ_PKG_SOURCE:=dnsmasq-$(DNSMASQ_VERSION)-dsmod-$(DNSMASQ_PKG_VERSION).tar.bz2
#DNSMASQ_PKG_SITE:=http://www.eiband.info/dsmod
DNSMASQ_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages


$(DL_DIR)/$(DNSMASQ_SOURCE):
	wget -P $(DL_DIR) $(DNSMASQ_SITE)/$(DNSMASQ_SOURCE)

$(DL_DIR)/$(DNSMASQ_PKG_SOURCE):
	@wget -P $(DL_DIR) $(DNSMASQ_PKG_SITE)/$(DNSMASQ_PKG_SOURCE)

$(DNSMASQ_DIR)/.unpacked: $(DL_DIR)/$(DNSMASQ_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(DNSMASQ_SOURCE)
	for i in $(DNSMASQ_MAKE_DIR)/patches/*.patch; do \
		patch -d $(DNSMASQ_DIR) -p0 < $$i; \
	done
	touch $@

$(DNSMASQ_DIR)/$(DNSMASQ_TARGET_BINARY): $(DNSMASQ_DIR)/.unpacked
	$(MAKE) CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-static-libgcc" \
		-C $(DNSMASQ_DIR)

$(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION): $(DL_DIR)/$(DNSMASQ_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) --exclude .svn -xjf $(DL_DIR)/$(DNSMASQ_PKG_SOURCE)
	@touch $@

dnsmasq: $(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION)

dnsmasq-package: $(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(DNSMASQ_PKG_SOURCE) dnsmasq-$(DNSMASQ_VERSION)

dnsmasq-precompiled: $(DNSMASQ_DIR)/$(DNSMASQ_TARGET_BINARY) dnsmasq
	$(TARGET_STRIP) $(DNSMASQ_DIR)/$(DNSMASQ_TARGET_BINARY)
	cp $(DNSMASQ_DIR)/$(DNSMASQ_TARGET_BINARY) $(DNSMASQ_TARGET_DIR)/

dnsmasq-source: $(DNSMASQ_DIR)/.unpacked $(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION)

dnsmasq-clean:
	-$(MAKE) -C $(DNSMASQ_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(DNSMASQ_PKG_SOURCE)

dnsmasq-dirclean:
	rm -rf $(DNSMASQ_DIR)
	rm -rf $(PACKAGES_DIR)/dnsmasq-$(DNSMASQ_VERSION)
	rm -f $(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION)

dnsmasq-list:
ifeq ($(strip $(DS_PACKAGE_DNSMASQ)),y)
	@echo "S40dnsmasq-$(DNSMASQ_VERSION)" >> .static
else
	@echo "S40dnsmasq-$(DNSMASQ_VERSION)" >> .dynamic
endif
