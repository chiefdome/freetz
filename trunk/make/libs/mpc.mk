$(call PKG_INIT_LIB, 0.8.2)
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=e98267ebd5648a39f881d66797122fb6
$(PKG)_SITE:=http://www.multiprecision.org/mpc/download

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libmpc.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpc.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libmpc.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := gmp mpfr

$(PKG)_CONFIGURE_OPTIONS += --with-gmp-build=$(TARGET_TOOLCHAIN_STAGING_DIR)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MPC_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(MPC_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpc.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MPC_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmpc.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/mpc*.h

$(pkg)-uninstall:
	$(RM) $(MPC_TARGET_DIR)/libmpc*.so*

$(PKG_FINISH)

# host version
MPC_DIR2:=$(TOOLS_SOURCE_DIR)/mpc-$(MPC_VERSION)
MPC_HOST_DIR:=$(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)
MPC_HOST_BINARY:=$(MPC_HOST_DIR)/lib/libmpc.a

$(MPC_DIR2)/.configured: $(GMP_HOST_BINARY) | $(MPC_DIR)/.unpacked
	mkdir -p $(MPC_DIR2)
	(cd $(MPC_DIR2); $(RM) config.cache; \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		$(FREETZ_BASE_DIR)/$(MPC_DIR)/configure \
		--prefix=$(MPC_HOST_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--disable-shared \
		--enable-static \
		--with-gmp=$(GMP_HOST_DIR) \
		--with-mpfr=$(MPFR_HOST_DIR) \
		$(DISABLE_NLS) \
	)
	touch $@

$(MPC_HOST_BINARY): $(MPC_DIR2)/.configured | $(TOOLS_BUILD_DIR)
	PATH=$(TARGET_PATH) $(MAKE) -C $(MPC_DIR2) install

host-libmpc: $(MPC_HOST_BINARY)

host-libmpc-uninstall:
	$(RM) $(MPC_HOST_DIR)/lib/libmpc* $(MPC_HOST_DIR)/include/*mpc*.h

host-libmpc-clean: host-libmpc-uninstall
	-$(MAKE) -C $(MPC_DIR2) clean

host-libmpc-dirclean: host-libmpc-uninstall
	$(RM) -r $(MPC_DIR2)
