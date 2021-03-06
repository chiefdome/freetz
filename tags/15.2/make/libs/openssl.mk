OPENSSL_VERSION:=0.9.8e
OPENSSL_LIB_VERSION:=0.9.8
OPENSSL_SOURCE:=openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_SITE:=http://www.openssl.org/source/
OPENSSL_MAKE_DIR:=$(MAKE_DIR)/libs
OPENSSL_DIR:=$(SOURCE_DIR)/openssl-$(OPENSSL_VERSION)
OPENSSL_SSL_BINARY:=$(OPENSSL_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
OPENSSL_CRYPTO_BINARY:=$(OPENSSL_DIR)/libcrypto.so.$(OPENSSL_LIB_VERSION)
OPENSSL_STAGING_SSL_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl.so.$(OPENSSL_LIB_VERSION)
OPENSSL_STAGING_CRYPTO_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto.so.$(OPENSSL_LIB_VERSION)
OPENSSL_TARGET_DIR:=root/usr/lib
OPENSSL_TARGET_SSL_BINARY:=$(OPENSSL_TARGET_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
OPENSSL_TARGET_CRYPTO_BINARY:=$(OPENSSL_TARGET_DIR)/libcrypto.so.$(OPENSSL_LIB_VERSION)

OPENSSL_NO_CIPHERS:= no-idea no-md2 no-mdc2 no-rc2 no-rc5 no-sha0 no-smime \
                    no-rmd160 no-aes192 no-ripemd no-camellia no-ans1 no-krb5
OPENSSL_OPTIONS:= shared no-ec no-err no-fips no-hw no-threads zlib-dynamic \
                    no-engines no-sse2 no-perlasm

$(DL_DIR)/$(OPENSSL_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(OPENSSL_SITE)/$(OPENSSL_SOURCE)

$(OPENSSL_DIR)/.unpacked: $(DL_DIR)/$(OPENSSL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(OPENSSL_SOURCE)
	for i in $(OPENSSL_MAKE_DIR)/patches/*.openssl.patch; do \
		$(PATCH_TOOL) $(OPENSSL_DIR) $$i; \
	done
	touch $@

$(OPENSSL_DIR)/.configured: $(OPENSSL_DIR)/.unpacked
	$(SED) -i -e 's/DS_MOD_OPTIMIZATION_FLAGS/$(TARGET_CFLAGS)/g' $(OPENSSL_DIR)/Configure
	( cd $(OPENSSL_DIR); \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		./Configure linux-ds-mod \
		--prefix=/usr \
		--openssldir=/mod/etc/ssl \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include \
		-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib \
		-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib -ldl \
		-DOPENSSL_SMALL_FOOTPRINT \
		$(OPENSSL_NO_CIPHERS) \
		$(OPENSSL_OPTIONS) \
	);
	touch $@

$(OPENSSL_SSL_BINARY) $(OPENSSL_CRYPTO_BINARY): $(OPENSSL_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) SHARED_LDFLAGS="" \
		$(MAKE1) CC="$(TARGET_CC)" \
		-C $(OPENSSL_DIR) \
		AR="$(TARGET_CROSS)ar r" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		all build-shared
	# Work around openssl build bug to link libssl.so with libcrypto.so.
	-rm $(OPENSSL_DIR)/libssl.so.*.*.*
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE1) \
		-C $(OPENSSL_DIR) \
		CC="$(TARGET_CC)" \
		CCOPTS="$(TARGET_CFLAGS) -fomit-frame-pointer" \
		do_linux-shared

$(OPENSSL_STAGING_SSL_BINARY) $(OPENSSL_STAGING_CRYPTO_BINARY): \
		$(OPENSSL_SSL_BINARY) $(OPENSSL_CRYPTO_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(OPENSSL_DIR) \
		INSTALL_PREFIX="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(OPENSSL_TARGET_SSL_BINARY): $(OPENSSL_STAGING_SSL_BINARY) 
	# FIXME: Strange enough, this chmod is really necessary. Maybe the
	# previous 'install' can be parametrised differently fo fix this.
	chmod 755 $(OPENSSL_STAGING_SSL_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl*.so* $(OPENSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(OPENSSL_TARGET_CRYPTO_BINARY): $(OPENSSL_STAGING_CRYPTO_BINARY)
	chmod 755 $(OPENSSL_STAGING_CRYPTO_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto*.so* $(OPENSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@
	
openssl: $(OPENSSL_STAGING_SSL_BINARY) $(OPENSSL_STAGING_CRYPTO_BINARY)

openssl-precompiled: uclibc zlib-precompiled openssl $(OPENSSL_TARGET_SSL_BINARY) $(OPENSSL_TARGET_CRYPTO_BINARY)

openssl-source: $(OPENSSL_DIR)/.unpacked

openssl-clean:
	-$(MAKE) -C $(OPENSSL_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/openssl
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssl*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcrypto*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/openssl

openssl-uninstall:
	rm -f $(OPENSSL_TARGET_DIR)/libssl*.so*
	rm -f $(OPENSSL_TARGET_DIR)/libcrypto*.so*

openssl-dirclean:
	rm -rf $(OPENSSL_DIR)
