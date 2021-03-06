CHECKMAILD_VERSION:=0.4.1
CHECKMAILD_MAKE_DIR:=$(MAKE_DIR)/checkmaild
CHECKMAILD_DIR:=$(SOURCE_DIR)/checkmaild-$(CHECKMAILD_VERSION)
CHECKMAILD_BINARY:=$(CHECKMAILD_DIR)/checkmaild
CHECKMAILD_TARGET_DIR:=$(PACKAGES_DIR)/checkmaild-$(CHECKMAILD_VERSION)
CHECKMAILD_TARGET_BINARY:=$(CHECKMAILD_TARGET_DIR)/root/usr/sbin/checkmaild
CHECKMAILD_PKG_SOURCE:=checkmaild-$(CHECKMAILD_VERSION)-dsmod.tar.bz2
CHECKMAILD_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages


$(CHECKMAILD_DIR)/.unpacked:
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(CHECKMAILD_MAKE_DIR)/source/checkmaild-$(CHECKMAILD_VERSION).tar.gz
	touch $@

$(CHECKMAILD_BINARY): $(CHECKMAILD_DIR)/.unpacked
	PATH=$(TARGET_MAKE_PATH):$(PATH); \
	$(MAKE) CROSS="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		-C $(CHECKMAILD_DIR)

$(CHECKMAILD_TARGET_BINARY): $(CHECKMAILD_BINARY)
	$(INSTALL_BINARY_STRIP)

$(DL_DIR)/$(CHECKMAILD_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(CHECKMAILD_PKG_SOURCE) $(CHECKMAILD_PKG_SITE)

$(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION): $(DL_DIR)/$(CHECKMAILD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CHECKMAILD_PKG_SOURCE)
	@touch $@

checkmaild: $(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION)

checkmaild-package: $(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(CHECKMAILD_PKG_SOURCE) checkmaild-$(CHECKMAILD_VERSION)

checkmaild-precompiled: uclibc checkmaild $(CHECKMAILD_TARGET_BINARY)

checkmaild-source: $(CHECKMAILD_DIR)/.unpacked $(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION)

checkmaild-clean:
	-$(MAKE) -C $(CHECKMAILD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(CHECKMAILD_PKG_SOURCE)

checkmaild-dirclean:
	rm -rf $(CHECKMAILD_DIR)
	rm -rf $(PACKAGES_DIR)/checkmaild-$(CHECKMAILD_VERSION)
	rm -f $(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION)

checkmaild-uninstall:
	rm -f $(CHECKMAILD_TARGET_BINARY)

checkmaild-list:
ifeq ($(strip $(DS_PACKAGE_CHECKMAILD)),y)
	@echo "S40checkmaild-$(CHECKMAILD_VERSION)" >> .static
else
	@echo "S40checkmaild-$(CHECKMAILD_VERSION)" >> .dynamic
endif
