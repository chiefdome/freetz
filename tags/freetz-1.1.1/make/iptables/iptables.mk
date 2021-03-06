$(call PKG_INIT_BIN, 1.4.1.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://netfilter.org/projects/$(pkg)/files
$(PKG)_BINARY:=$($(PKG)_DIR)/iptables
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libiptc/libiptc.a
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/iptables
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiptc.a
$(PKG)_EXTENSIONS_DIR:=$(ROOT_DIR)/usr/lib/xtables
$(PKG)_TARGET_EXTENSIONS:=$($(PKG)_EXTENSIONS_DIR)/.installed
$(PKG)_CONFIGURE_ENV += AR="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)ar" RANLIB="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)ranlib"
$(PKG)_CONFIGURE_OPTIONS += --with-ksource="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured | kernel-source
	find "$(IPTABLES_DIR)" -name "*ip6*" -o -name "*ipv6*" | xargs rm -rf
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(IPTABLES_DIR)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/  
	cp $< $@  

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_EXTENSIONS): $($(PKG)_BINARY)
	mkdir -p $(IPTABLES_EXTENSIONS_DIR)
	cp $(IPTABLES_DIR)/extensions/*.so $(IPTABLES_EXTENSIONS_DIR)/
	$(TARGET_STRIP) $(IPTABLES_EXTENSIONS_DIR)/*.so
	touch $@

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_EXTENSIONS) $($(PKG)_LIB_STAGING_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(IPTABLES_DIR) clean
	$(RM) $(IPTABLES_LIB_STAGING_BINARY)

$(pkg)-uninstall:
	$(RM) $(IPTABLES_TARGET_BINARY)
	$(RM) $(IPTABLES_EXTENSIONS_DIR)/*

$(PKG_FINISH)
