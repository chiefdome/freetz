$(call PKG_INIT_LIB, 0.8.10)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.mr511.de/software
$(PKG)_BINARY:=$($(PKG)_DIR)/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;
$(PKG)_CONFIGURE_ENV += mr_cv_working_memmove=yes
$(PKG)_CONFIGURE_ENV += mr_cv_target_elf=yes
$(PKG)_CONFIGURE_ENV += libelf_64bit=yes
$(PKG)_CONFIGURE_ENV += libelf_cv_struct_elf64_ehdr=yes
$(PKG)_CONFIGURE_ENV += libelf_cv_type_elf64_addr=no
$(PKG)_CONFIGURE_ENV += libelf_cv_struct_elf64_rel=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-elf64=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBELF_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE1) \
		instroot="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(LIBELF_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libelf.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*.so* $(LIBELF_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIBELF_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libelf*

$(pkg)-uninstall:
	rm -f $(LIBELF_TARGET_DIR)/libelf*.so*

$(PKG_FINISH)
