CHECKMAILD_VERSION:=0.2
CHECKMAILD_DIR:=$(SOURCE_DIR)/checkmaild
CHECKMAILD_MAKE_DIR:=$(MAKE_DIR)/checkmaild
CHECKMAILD_TARGET_DIR:=$(PACKAGES_DIR)/checkmaild-$(CHECKMAILD_VERSION)/root/usr/sbin
CHECKMAILD_TARGET_BINARY:=checkmaild
CHECKMAILD_PKG_SOURCE:=checkmaild-$(CHECKMAILD_VERSION)-dsmod.tar.bz2
CHECKMAILD_PKG_SITE:=http://dsmod.magenbrot.net


$(CHECKMAILD_DIR)/.unpacked:
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(CHECKMAILD_MAKE_DIR)/source/checkmaild.tar.gz
	touch $@

$(CHECKMAILD_DIR)/$(CHECKMAILD_TARGET_BINARY): $(CHECKMAILD_DIR)/.unpacked
	PATH=$(TARGET_MAKE_PATH):$(PATH); \
	$(MAKE) CROSS="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-static-libgcc" \
		-C $(CHECKMAILD_DIR)

$(DL_DIR)/$(CHECKMAILD_PKG_SOURCE):
	@wget -P $(DL_DIR) $(CHECKMAILD_PKG_SITE)/$(CHECKMAILD_PKG_SOURCE)

$(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION): $(DL_DIR)/$(CHECKMAILD_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CHECKMAILD_PKG_SOURCE)
	@touch $@

checkmaild: $(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION)

checkmaild-package: $(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(CHECKMAILD_PKG_SOURCE) checkmaild-$(CHECKMAILD_VERSION)

checkmaild-precompiled: $(CHECKMAILD_DIR)/$(CHECKMAILD_TARGET_BINARY) checkmaild
	$(TARGET_STRIP) $(CHECKMAILD_DIR)/$(CHECKMAILD_TARGET_BINARY)
	cp $(CHECKMAILD_DIR)/$(CHECKMAILD_TARGET_BINARY) $(CHECKMAILD_TARGET_DIR)/

checkmaild-source: $(CHECKMAILD_DIR)/.unpacked $(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION)

checkmaild-clean:
	-$(MAKE) -C $(CHECKMAILD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(CHECKMAILD_PKG_SOURCE)

checkmaild-dirclean:
	rm -rf $(CHECKMAILD_DIR)
	rm -rf $(PACKAGES_DIR)/checkmaild-$(CHECKMAILD_VERSION)
	rm -f $(PACKAGES_DIR)/.checkmaild-$(CHECKMAILD_VERSION)

checkmaild-list:
ifeq ($(strip $(DS_PACKAGE_CHECKMAILD)),y)
	@echo "S40checkmaild-$(CHECKMAILD_VERSION)" >> .static
else
	@echo "S40checkmaild-$(CHECKMAILD_VERSION)" >> .dynamic
endif
