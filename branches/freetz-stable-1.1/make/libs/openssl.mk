$(call PKG_INIT_LIB, 0.9.8n)
$(PKG)_LIB_VERSION:=0.9.8
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=076d8efc3ed93646bd01f04e23c07066
$(PKG)_SITE:=http://www.openssl.org/source

$(PKG)_SSL_BINARY:=$($(PKG)_DIR)/libssl.so.$($(PKG)_LIB_VERSION)
$(PKG)_CRYPTO_BINARY:=$($(PKG)_DIR)/libcrypto.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_SSL_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_CRYPTO_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_SSL_BINARY:=$($(PKG)_TARGET_DIR)/libssl.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_CRYPTO_BINARY:=$($(PKG)_TARGET_DIR)/libcrypto.so.$($(PKG)_LIB_VERSION)

OPENSSL_NO_CIPHERS:= no-idea no-md2 no-mdc2 no-rc2 no-rc5 no-sha0 no-smime \
	no-rmd160 no-aes192 no-ripemd no-camellia no-ans1 no-krb5
OPENSSL_OPTIONS:= shared no-ec no-err no-fips no-hw no-engines \
	no-sse2 no-perlasm

$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -e 's/FREETZ_MOD_OPTIMIZATION_FLAGS/$(TARGET_CFLAGS)/g' Configure;
$(PKG)_CONFIGURE_PRE_CMDS += ln -s Configure configure;

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_OPTIONS += linux-freetz
$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --openssldir=/mod/etc/ssl
$(PKG)_CONFIGURE_OPTIONS += -DOPENSSL_SMALL_FOOTPRINT
$(PKG)_CONFIGURE_OPTIONS += $(OPENSSL_NO_CIPHERS)
$(PKG)_CONFIGURE_OPTIONS += $(OPENSSL_OPTIONS)
#$(PKG)_CONFIGURE_OPTIONS += -ldl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_SSL_BINARY) $($(PKG)_CRYPTO_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		SHARED_LDFLAGS="" \
		$(MAKE) -C $(OPENSSL_DIR) \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_CROSS)ar r" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		all
	# Work around openssl build bug to link libssl.so with libcrypto.so.
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(OPENSSL_DIR) \
		CC="$(TARGET_CC)" \
		CCOPTS="$(TARGET_CFLAGS) -fomit-frame-pointer" \
		do_linux-shared

$($(PKG)_STAGING_SSL_BINARY) $($(PKG)_STAGING_CRYPTO_BINARY): \
		$($(PKG)_SSL_BINARY) $($(PKG)_CRYPTO_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(OPENSSL_DIR) \
		INSTALL_PREFIX="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libcrypto.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libssl.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/openssl.pc

$($(PKG)_TARGET_SSL_BINARY): $($(PKG)_STAGING_SSL_BINARY) 
	# FIXME: Strange enough, this chmod is really necessary. Maybe the
	# previous 'install' can be parametrised differently fo fix this.
	chmod 755 $(OPENSSL_STAGING_SSL_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl*.so* $(OPENSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PKG)_TARGET_CRYPTO_BINARY): $($(PKG)_STAGING_CRYPTO_BINARY)
	chmod 755 $(OPENSSL_STAGING_CRYPTO_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto*.so* $(OPENSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_SSL_BINARY) $($(PKG)_STAGING_CRYPTO_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_SSL_BINARY) $($(PKG)_TARGET_CRYPTO_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(OPENSSL_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/openssl
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl*
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/openssl

$(pkg)-uninstall:
	$(RM) $(OPENSSL_TARGET_DIR)/libssl*.so*
	$(RM) $(OPENSSL_TARGET_DIR)/libcrypto*.so*

$(PKG_FINISH)
