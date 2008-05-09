BUSYBOX_MAKE_DIR:=$(MAKE_DIR)/busybox
BUSYBOX_REF_DIR:=$(SOURCE_DIR)/ref-$(BUSYBOX_REF)

BUSYBOX_VERSION:=1.9.2
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
		$(PATCH_TOOL) $(BUSYBOX_DIR) $$i; \
	done
	touch $@

$(BUSYBOX_CUSTOM_CONFIG_FILE): $(TOPDIR)/.config $(BUSYBOX_CONFIG_FILE)
	@cp -p $(BUSYBOX_CONFIG_FILE) $(BUSYBOX_CUSTOM_CONFIG_TEMP)
	@$(call PKG_EDIT_CONFIG, \
		CONFIG_INETD=$(FREETZ_BUSYBOX_INETD) \
		CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_TIME=$(FREETZ_BUSYBOX_INETD) \
		CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_DAYTIME=$(FREETZ_BUSYBOX_INETD) \
		CONFIG_AR=$(FREETZ_BUSYBOX_AR) \
		CONFIG_FEATURE_AR_LONG_FILENAMES=$(FREETZ_BUSYBOX_AR) \
		CONFIG_DIFF=$(FREETZ_BUSYBOX_DIFF) \
		CONFIG_FEATURE_DIFF_BINARY=$(FREETZ_BUSYBOX_DIFF) \
		CONFIG_FEATURE_DIFF_DIR=$(FREETZ_BUSYBOX_DIFF) \
		CONFIG_FEATURE_DIFF_MINIMAL=$(FREETZ_BUSYBOX_DIFF) \
		CONFIG_PATCH=$(FREETZ_BUSYBOX_PATCH) \
		CONFIG_START_STOP_DAEMON=$(FREETZ_BUSYBOX_START_STOP_DAEMON) \
		CONFIG_FEATURE_START_STOP_DAEMON_FANCY=$(FREETZ_BUSYBOX_START_STOP_DAEMON) \
		CONFIG_WGET=$(FREETZ_BUSYBOX_WGET) \
		CONFIG_LESS=$(FREETZ_BUSYBOX_LESS) \
		CONFIG_FEATURE_LESS_BRACKETS=$(FREETZ_BUSYBOX_LESS) \
		CONFIG_FEATURE_LESS_REGEXP=$(FREETZ_BUSYBOX_LESS) \
		CONFIG_FEATURE_LESS_FLAGS=$(FREETZ_BUSYBOX_LESS) \
		CONFIG_NICE=$(FREETZ_BUSYBOX_NICE) \
		CONFIG_FEATURE_LS_COLOR=$(FREETZ_BUSYBOX_LS_COLOR) \
		CONFIG_FEATURE_LS_COLOR_IS_DEFAULT=$(FREETZ_BUSYBOX_LS_COLOR) \
		CONFIG_NICE=$(FREETZ_BUSYBOX_NICE) \
		CONFIG_FEATURE_EDITING_FANCY_KEYS=$(FREETZ_BUSYBOX_KEYS) \
		CONFIG_FEATURE_FAST_TOP=$(FREETZ_BUSYBOX_FASTPROC) \
	) $(BUSYBOX_CUSTOM_CONFIG_TEMP)
	@diff -q $(BUSYBOX_CUSTOM_CONFIG_TEMP) $(BUSYBOX_CUSTOM_CONFIG_FILE) || \
		cp $(BUSYBOX_CUSTOM_CONFIG_TEMP) $(BUSYBOX_CUSTOM_CONFIG_FILE)
	@rm -f $(BUSYBOX_CUSTOM_CONFIG_TEMP)

$(BUSYBOX_DIR)/.configured: $(BUSYBOX_DIR)/.unpacked $(BUSYBOX_CUSTOM_CONFIG_FILE) 
	cp $(BUSYBOX_CUSTOM_CONFIG_FILE) $(BUSYBOX_DIR)/.config
	$(call PKG_EDIT_CONFIG, CONFIG_LFS=$(FREETZ_TARGET_LFS)) $(BUSYBOX_DIR)/.config
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
	mkdir -p $(BUSYBOX_TARGET_DIR)
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
