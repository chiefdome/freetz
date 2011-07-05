$(call PKG_INIT_BIN, 1.4.11.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=7de6e1ae7ed8a2025f184763a6a24b9a
$(PKG)_SITE:=http://netfilter.org/projects/$(pkg)/files
$(PKG)_CONDITIONAL_PATCHES+=$(KERNEL_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPTABLES_SAVE_RESTORE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPTABLES_XML

$(PKG)_BINARY := $($(PKG)_DIR)/iptables/.libs/xtables-multi
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/sbin/xtables-multi

$(PKG)_LIBS_SUBDIRS := libiptc/.libs/
$(PKG)_LIBS_SUBDIRS += iptables/.libs/
ifeq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_LIBS_SUBDIRS += libiptc/.libs/
endif

$(PKG)_LIBNAMES_ALL := libip4tc.so.0.0.0 libxtables.so.6.0.0 libip6tc.so.0.0.0
$(PKG)_LIBNAMES := $(filter-out $(if $(FREETZ_TARGET_IPV6_SUPPORT),,libip6tc%), $($(PKG)_LIBNAMES_ALL))
$(PKG)_LIBS_BUILD_DIR := $(addprefix $($(PKG)_DIR)/,$(join $($(PKG)_LIBS_SUBDIRS),$($(PKG)_LIBNAMES)))
$(PKG)_LIBS_TARGET_DIR := $(addprefix $($(PKG)_DEST_LIBDIR)/,$($(PKG)_LIBNAMES))

$(PKG)_SYMLINKS_ALL := iptables iptables-save iptables-restore iptables-xml ip6tables ip6tables-save ip6tables-restore
$(PKG)_SYMLINKS := $(filter-out $(if $(FREETZ_TARGET_IPV6_SUPPORT),,ip6%) $(if $(FREETZ_PACKAGE_IPTABLES_SAVE_RESTORE),,%-save %-restore) $(if $(FREETZ_PACKAGE_IPTABLES_XML),,%-xml), $($(PKG)_SYMLINKS_ALL))
$(PKG)_SYMLINKS_TARGET_DIR := $($(PKG)_SYMLINKS:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_EXTENSIONS_DIR := $($(PKG)_DIR)/extensions
$(PKG)_EXTENSIONS_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/lib/xtables


$(PKG)_CONFIGURE_ENV += AR="$(TARGET_AR)"
$(PKG)_CONFIGURE_ENV += RANLIB="$(TARGET_RANLIB)"
$(PKG)_CONFIGURE_OPTIONS += --with-ksource="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --enable-ipv4
ifneq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
endif
ifeq ($(strip $(FREETZ_PACKAGE_IPTABLES_SAVE_RESTORE)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-save-restore
endif
ifeq ($(strip $(FREETZ_PACKAGE_IPTABLES_XML)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-xml
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,ac_cv(_header_linux),do_not_cache_me\1,g' configure;

# touch some patched files to prevent auto*-tools from being executed
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARY): $($(PKG)_DIR)/.configured | kernel-source
	$(SUBMAKE) -C $(IPTABLES_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

define $(PKG)_SYMLINK_RULE
$$(filter $($(PKG)_DEST_DIR)/usr/sbin/$(1)%,$($(PKG)_SYMLINKS_TARGET_DIR)): $($(PKG)_TARGET_BINARY)
	ln -sf $$(notdir $$<) $$@
endef
$(eval $(call $(PKG)_SYMLINK_RULE,iptables))
ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(eval $(call $(PKG)_SYMLINK_RULE,ip6tables))
endif

$($(PKG)_TARGET_EXTENSIONS): $($(PKG)_BINARY)
	mkdir -p $(IPTABLES_EXTENSIONS_DIR)
	cp $(IPTABLES_EXTENSIONS_DIR)/*.so* $(IPTABLES_EXTENSIONS_TARGET_DIR)
	$(TARGET_STRIP) $(IPTABLES_EXTENSIONS_DIR)/*.so*
	touch $@

$(foreach library,$($(PKG)_LIBS_BUILD_DIR),$(eval $(call INSTALL_LIBRARY_STRIP_RULE,$(library),$(FREETZ_LIBRARY_PATH))))

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARY) $($(PKG)_SYMLINKS_TARGET_DIR) $($(PKG)_TARGET_EXTENSIONS)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IPTABLES_DIR) clean

$(pkg)-uninstall:
	$(RM) -r \
		$(IPTABLES_TARGET_BINARY) \
		$(IPTABLES_DEST_LIBDIR)/lib* \
		$(IPTABLES_EXTENSIONS_TARGET_DIR)

$(PKG_FINISH)
