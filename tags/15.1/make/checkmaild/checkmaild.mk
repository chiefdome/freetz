CHECKMAILD_VERSION:=0.4.2
CHECKMAILD_SOURCE:=checkmaild-$(CHECKMAILD_VERSION).tar.bz2
CHECKMAILD_SITE:=http://dsmod.magenbrot.net
CHECKMAILD_MAKE_DIR:=$(MAKE_DIR)/checkmaild
CHECKMAILD_DIR:=$(SOURCE_DIR)/checkmaild-$(CHECKMAILD_VERSION)
CHECKMAILD_BINARY:=$(CHECKMAILD_DIR)/checkmaild
CHECKMAILD_PKG_VERSION:=0.1
CHECKMAILD_PKG_NAME:=checkmaild-$(CHECKMAILD_VERSION)
CHECKMAILD_PKG_SOURCE:=checkmaild-$(CHECKMAILD_VERSION)-dsmod-$(CHECKMAILD_PKG_VERSION).tar.bz2
CHECKMAILD_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
CHECKMAILD_TARGET_DIR:=$(PACKAGES_DIR)/$(CHECKMAILD_PKG_NAME)
CHECKMAILD_TARGET_BINARY:=$(CHECKMAILD_TARGET_DIR)/root/usr/sbin/checkmaild

$(DL_DIR)/$(CHECKMAILD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(CHECKMAILD_SITE)/$(CHECKMAILD_SOURCE)

$(DL_DIR)/$(CHECKMAILD_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(CHECKMAILD_PKG_SOURCE) $(CHECKMAILD_PKG_SITE)

$(CHECKMAILD_DIR)/.unpacked: $(DL_DIR)/$(CHECKMAILD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(CHECKMAILD_SOURCE)
	touch $@

$(CHECKMAILD_BINARY): $(CHECKMAILD_DIR)/.unpacked
	PATH=$(TARGET_MAKE_PATH):$(PATH); \
	$(MAKE) CROSS="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-lpthread" \
		-C $(CHECKMAILD_DIR)

$(CHECKMAILD_TARGET_BINARY): $(CHECKMAILD_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(CHECKMAILD_PKG_NAME): $(DL_DIR)/$(CHECKMAILD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CHECKMAILD_PKG_SOURCE)
	@touch $@

checkmaild: $(PACKAGES_DIR)/.$(CHECKMAILD_PKG_NAME)

checkmaild-package: $(PACKAGES_DIR)/.$(CHECKMAILD_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(CHECKMAILD_PKG_SOURCE) $(CHECKMAILD_PKG_NAME)

checkmaild-precompiled: uclibc checkmaild $(CHECKMAILD_TARGET_BINARY)

checkmaild-source: $(CHECKMAILD_DIR)/.unpacked $(PACKAGES_DIR)/.$(CHECKMAILD_PKG_NAME)

checkmaild-clean:
	-$(MAKE) -C $(CHECKMAILD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(CHECKMAILD_PKG_SOURCE)

checkmaild-dirclean:
	rm -rf $(CHECKMAILD_DIR)
	rm -rf $(PACKAGES_DIR)/$(CHECKMAILD_PKG_NAME)
	rm -f $(PACKAGES_DIR)/..$(CHECKMAILD_PKG_NAME)

checkmaild-uninstall:
	rm -f $(CHECKMAILD_TARGET_BINARY)

checkmaild-list:
ifeq ($(strip $(DS_PACKAGE_CHECKMAILD)),y)
	@echo "S40checkmaild-$(CHECKMAILD_VERSION)" >> .static
else
	@echo "S40checkmaild-$(CHECKMAILD_VERSION)" >> .dynamic
endif
