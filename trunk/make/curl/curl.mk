$(call PKG_INIT_BIN, 7.21.2)
$(PKG)_LIB_VERSION:=4.2.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=ca96df88e044c7c25d19692ec8b250b2
$(PKG)_SITE:=http://curl.haxx.se/download

ifeq ($(strip $(FREETZ_PACKAGE_CURL_STATIC)),y)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/curl
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/libcurl.a
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl.a
$(PKG)_LDFLAGS:=-all-static
else
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/curl
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/libcurl.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libcurl.so.$($(PKG)_LIB_VERSION)
endif

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/curl

$(PKG)_DEPENDS_ON := openssl
ifeq ($(strip $(FREETZ_PACKAGE_CURL_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CURL_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CURL_STATIC

$(PKG)_CONFIGURE_ENV += curl_cv_writable_argv=yes

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_CURL_STATIC),--disable-shared,--enable-shared)
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld
$(PKG)_CONFIGURE_OPTIONS += --disable-thread
$(PKG)_CONFIGURE_OPTIONS += --enable-cookies
$(PKG)_CONFIGURE_OPTIONS += --enable-crypto-auth
$(PKG)_CONFIGURE_OPTIONS += --enable-nonblocking
$(PKG)_CONFIGURE_OPTIONS += --enable-file
$(PKG)_CONFIGURE_OPTIONS += --enable-ftp
$(PKG)_CONFIGURE_OPTIONS += --enable-http
$(PKG)_CONFIGURE_OPTIONS += --disable-ares
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-dict
$(PKG)_CONFIGURE_OPTIONS += --disable-gopher
$(PKG)_CONFIGURE_OPTIONS += --disable-ldap
$(PKG)_CONFIGURE_OPTIONS += --disable-manual
$(PKG)_CONFIGURE_OPTIONS += --disable-sspi
$(PKG)_CONFIGURE_OPTIONS += --disable-telnet
$(PKG)_CONFIGURE_OPTIONS += --disable-verbose
$(PKG)_CONFIGURE_OPTIONS += --with-random="/dev/urandom"
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-ca-bundle
$(PKG)_CONFIGURE_OPTIONS += --without-gnutls
$(PKG)_CONFIGURE_OPTIONS += --without-libidn
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_CURL_WITH_ZLIB),--with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-zlib)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CURL_DIR) \
		LDFLAGS="$(CURL_LDFLAGS)"

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(CURL_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libcurl.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/curl-config

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

ifeq ($(strip $(FREETZ_PACKAGE_CURL_STATIC)),y)
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_STAGING_BINARY)
else
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)
endif

$(pkg)-clean:
	-$(SUBMAKE) -C $(CURL_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libcurl.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/curl \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/curl*

$(pkg)-uninstall:
	$(RM) $(CURL_TARGET_BINARY)
	$(RM) $(CURL_TARGET_LIBDIR)/libcurl*.so*

$(PKG_FINISH)
