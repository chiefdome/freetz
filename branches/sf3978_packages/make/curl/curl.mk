$(call PKG_INIT_BIN, 7.23.1)
$(PKG)_LIB_VERSION:=4.2.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=0296d3196b4bf82c896a869b38dbc5f2
$(PKG)_SITE:=http://curl.haxx.se/download

$(PKG)_BINARY:=$($(PKG)_DIR)/src$(if $(FREETZ_PACKAGE_CURL_STATIC),,/.libs)/curl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/curl
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/libcurl.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libcurl.so.$($(PKG)_LIB_VERSION)

ifeq ($(strip $(FREETZ_PACKAGE_CURL_WITH_SSL)),y)
ifeq ($(strip $(FREETZ_PACKAGE_CURL_USE_POLARSSL)),y)
$(PKG)_DEPENDS_ON := polarssl
else
$(PKG)_DEPENDS_ON := openssl
FREETZ_PACKAGE_CURL_USE_OPENSSL := y
endif
endif
ifeq ($(strip $(FREETZ_PACKAGE_CURL_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CURL_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CURL_USE_POLARSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CURL_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CURL_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_ENV += curl_cv_writable_argv=yes

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
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
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_CURL_USE_OPENSSL),--with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-ssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_CURL_USE_POLARSSL),--with-polarssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-polarssl)
$(PKG)_CONFIGURE_OPTIONS += --without-ca-bundle
$(PKG)_CONFIGURE_OPTIONS += --without-cyassl
$(PKG)_CONFIGURE_OPTIONS += --without-gnutls
$(PKG)_CONFIGURE_OPTIONS += --without-libidn
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_CURL_WITH_ZLIB),--with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-zlib)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CURL_DIR) \
		$(if $(FREETZ_PACKAGE_CURL_STATIC),STATIC_LDFLAGS=-all-static)

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

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CURL_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libcurl.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/curl \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/curl*

$(pkg)-uninstall:
	$(RM) $(CURL_TARGET_BINARY)
	$(RM) $(CURL_TARGET_LIBDIR)/libcurl*.so*

$(call PKG_ADD_LIB,libcurl)
$(PKG_FINISH)
