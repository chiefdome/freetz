$(call PKG_INIT_LIB, 7.9)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre
$(PKG)_SOURCE_MD5:=b6a9669d1863423f01ea46cdf00f93dc

$(PKG)_LIB_VERSION:=0.0.1
$(PKG)_LIBNAME=libpcre.so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_POSIX_LIB_VERSION:=0.0.0
$(PKG)_POSIX_LIBNAME=libpcreposix.so.$($(PKG)_POSIX_LIB_VERSION)
$(PKG)_POSIX_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_POSIX_LIBNAME)
$(PKG)_POSIX_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_POSIX_LIBNAME)
$(PKG)_POSIX_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_POSIX_LIBNAME)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-utf8
$(PKG)_CONFIGURE_OPTIONS += --disable-cpp

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_POSIX_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(PCRE_DIR) \
		CFLAGS="$(TARGET_CFLAGS)"\
		all

$($(PKG)_STAGING_BINARY) $($(PKG)_POSIX_STAGING_BINARY): $($(PKG)_BINARY) $($(PKG)_POSIX_BINARY)
	PATH=$(TARGET_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(PCRE_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcreposix.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcre-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_POSIX_TARGET_BINARY): $($(PKG)_POSIX_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY) $($(PKG)_POSIX_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_POSIX_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PCRE_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre*.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pcre*.h

$(pkg)-uninstall:
	$(RM) $(PCRE_TARGET_DIR)/libpcre*.so*

$(PKG_FINISH)
