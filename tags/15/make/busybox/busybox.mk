BUSYBOX_MAKE_DIR:=$(MAKE_DIR)/busybox
BUSYBOX_REF_DIR:=$(SOURCE_DIR)/ref-$(BUSYBOX_REF)

BUSYBOX_VERSION:=1.5.1
BUSYBOX_DIR:=$(BUSYBOX_REF_DIR)/busybox-$(BUSYBOX_VERSION)
BUSYBOX_CONFIG_FILE:=$(BUSYBOX_MAKE_DIR)/Config.$(BUSYBOX_REF)
BUSYBOX_CUSTOM_CONFIG_FILE:=$(BUSYBOX_MAKE_DIR)/Config.custom
BUSYBOX_CUSTOM_CONFIG_TEMP:=$(BUSYBOX_MAKE_DIR)/Config.temp

BUSYBOX_SOURCE:=busybox-$(BUSYBOX_VERSION).tar.bz2
BUSYBOX_SITE:=http://www.busybox.net/downloads
BUSYBOX_TARGET_DIR:=busybox
BUSYBOX_TARGET_BINARY:=busybox


$(DL_DIR)/$(BUSYBOX_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(BUSYBOX_SITE)/$(BUSYBOX_SOURCE)

$(BUSYBOX_DIR)/.unpacked: $(DL_DIR)/$(BUSYBOX_SOURCE)
	mkdir -p $(BUSYBOX_REF_DIR)
	tar -C $(BUSYBOX_REF_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BUSYBOX_SOURCE)
	for i in $(BUSYBOX_MAKE_DIR)/patches/*.patch; do \
		patch -d $(BUSYBOX_DIR) -p0 < $$i; \
	done
	touch $@

$(BUSYBOX_CUSTOM_CONFIG_FILE): $(TOPDIR)/.config $(BUSYBOX_CONFIG_FILE)
	@cat $(BUSYBOX_CONFIG_FILE) \
		| $(SED) -r \
			-e 's/^(# )?(CONFIG_INETD).*/\2=$(if $(DS_BUSYBOX_INETD),y,n)/' \
			-e 's/^(# )?(CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_TIME).*/\2=$(if $(DS_BUSYBOX_INETD),y,n)/' \
			-e 's/^(# )?(CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_DAYTIME).*/\2=$(if $(DS_BUSYBOX_INETD),y,n)/' \
			-e 's/^(# )?(CONFIG_AR)\b.*/\2=$(if $(DS_BUSYBOX_AR),y,n)/' \
			-e 's/^(# )?(CONFIG_FEATURE_AR_LONG_FILENAMES).*/\2=$(if $(DS_BUSYBOX_AR),y,n)/' \
			-e 's/^(# )?(CONFIG_DIFF).*/\2=$(if $(DS_BUSYBOX_DIFF),y,n)/' \
			-e 's/^(# )?(CONFIG_FEATURE_DIFF_BINARY).*/\2=$(if $(DS_BUSYBOX_DIFF),y,n)/' \
			-e 's/^(# )?(CONFIG_FEATURE_DIFF_DIR).*/\2=$(if $(DS_BUSYBOX_DIFF),y,n)/' \
			-e 's/^(# )?(CONFIG_FEATURE_DIFF_MINIMAL).*/\2=$(if $(DS_BUSYBOX_DIFF),y,n)/' \
			-e 's/^(# )?(CONFIG_PATCH).*/\2=$(if $(DS_BUSYBOX_PATCH),y,n)/' \
		> $(BUSYBOX_CUSTOM_CONFIG_TEMP)
	@diff -q $(BUSYBOX_CUSTOM_CONFIG_TEMP) $(BUSYBOX_CUSTOM_CONFIG_FILE) || \
		cp $(BUSYBOX_CUSTOM_CONFIG_TEMP) $(BUSYBOX_CUSTOM_CONFIG_FILE)
	@rm -f $(BUSYBOX_CUSTOM_CONFIG_TEMP)

$(BUSYBOX_DIR)/.configured: $(BUSYBOX_DIR)/.unpacked $(BUSYBOX_CUSTOM_CONFIG_FILE) 
	cp $(BUSYBOX_CUSTOM_CONFIG_FILE) $(BUSYBOX_DIR)/.config
ifeq ($(DS_TARGET_LFS),y)
	$(SED) -i -e "s/^.*CONFIG_LFS.*/CONFIG_LFS=y/;" $(BUSYBOX_DIR)/.config
else
	$(SED) -i -e "s/^.*CONFIG_LFS.*/# CONFIG_LFS is not set/;" $(BUSYBOX_DIR)/.config
endif
	$(MAKE) CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		-C $(BUSYBOX_DIR) oldconfig
	touch $@

$(BUSYBOX_DIR)/$(BUSYBOX_TARGET_BINARY): $(BUSYBOX_DIR)/.configured
	$(MAKE) CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		ARCH="mipsel" \
		-C $(BUSYBOX_DIR)

$(BUSYBOX_DIR)/busybox.links: $(BUSYBOX_DIR)/$(BUSYBOX_TARGET_BINARY)
	$(MAKE) CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		-C $(BUSYBOX_DIR) busybox.links
	touch $@

$(BUSYBOX_TARGET_DIR)/busybox-$(BUSYBOX_REF): $(BUSYBOX_DIR)/$(BUSYBOX_TARGET_BINARY)
	$(INSTALL_BINARY_STRIP)

$(BUSYBOX_TARGET_DIR)/busybox-$(BUSYBOX_REF).links: $(BUSYBOX_DIR)/busybox.links
	cp $(BUSYBOX_DIR)/busybox.links $(BUSYBOX_TARGET_DIR)/busybox-$(BUSYBOX_REF).links

busybox-source: $(BUSYBOX_DIR)/.unpacked

busybox-menuconfig: $(BUSYBOX_DIR)/.unpacked $(BUSYBOX_CONFIG_FILE)
	cp $(BUSYBOX_CONFIG_FILE) $(BUSYBOX_DIR)/.config
	$(MAKE) CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		-C $(BUSYBOX_DIR) menuconfig
	cp $(BUSYBOX_DIR)/.config $(BUSYBOX_CONFIG_FILE)

busybox-oldconfig: $(BUSYBOX_DIR)/.configured
	
busybox-precompiled: uclibc $(BUSYBOX_TARGET_DIR)/busybox-$(BUSYBOX_REF) $(BUSYBOX_TARGET_DIR)/busybox-$(BUSYBOX_REF).links

busybox-clean: busybox-uninstall
	-$(MAKE) -C $(BUSYBOX_DIR) clean

busybox-uninstall:
	rm -rf $(BUSYBOX_TARGET_DIR)/busybox-$(BUSYBOX_REF) \
		$(BUSYBOX_TARGET_DIR)/busybox-$(BUSYBOX_REF).links

busybox-dirclean:
	rm -rf $(BUSYBOX_DIR)

.PHONY: busybox-menuconfig busybox-oldconfig
