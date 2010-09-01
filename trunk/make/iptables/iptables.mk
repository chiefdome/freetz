$(call PKG_INIT_BIN, 1.4.1.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=723fa88d8a0915e184f99e03e9bf06cb
$(PKG)_SITE:=http://netfilter.org/projects/$(pkg)/files
ifneq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_CONDITIONAL_PATCHES+=cond
endif

$(PKG)_BINARIES_ALL:=iptables ip6tables iptables-save iptables-restore
$(PKG)_BINARIES:=\
	$(filter-out \
		$(if $(FREETZ_TARGET_IPV6_SUPPORT),,ip6tables) \
		$(if $(FREETZ_PACKAGE_IPTABLES_SAVE_RESTORE),,iptables-save iptables-restore), \
		$($(PKG)_BINARIES_ALL) \
	)
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_LIB_BUILD_DIR:=$($(PKG)_DIR)/libiptc/libiptc.a
$(PKG)_LIB_STAGING_DIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiptc.a
$(PKG)_EXTENSIONS_DIR:=$(TARGET_SPECIFIC_ROOT_DIR)/usr/lib/xtables
$(PKG)_TARGET_EXTENSIONS:=$($(PKG)_EXTENSIONS_DIR)/.installed

$(PKG)_CONFIGURE_ENV += AR="$(TARGET_AR)"
$(PKG)_CONFIGURE_ENV += RANLIB="$(TARGET_RANLIB)"
$(PKG)_CONFIGURE_OPTIONS += --with-ksource="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIB_BUILD_DIR): $($(PKG)_DIR)/.configured | kernel-source
	$(SUBMAKE) -C $(IPTABLES_DIR)

$($(PKG)_LIB_STAGING_DIR): $($(PKG)_LIB_BUILD_DIR)
	$(INSTALL_FILE)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_EXTENSIONS): $($(PKG)_BINARIES_BUILD_DIR)
	mkdir -p $(IPTABLES_EXTENSIONS_DIR)
	cp $(IPTABLES_DIR)/extensions/*.so $(IPTABLES_EXTENSIONS_DIR)/
	$(TARGET_STRIP) $(IPTABLES_EXTENSIONS_DIR)/*.so
	touch $@

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_TARGET_EXTENSIONS) $($(PKG)_LIB_STAGING_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IPTABLES_DIR) clean
	$(RM) $(IPTABLES_LIB_STAGING_DIR)

$(pkg)-uninstall:
	$(RM) \
		$(IPTABLES_BINARIES_ALL:%=$(IPTABLES_DEST_DIR)/usr/sbin/%) \
		$(IPTABLES_EXTENSIONS_DIR)/*

$(PKG_FINISH)
