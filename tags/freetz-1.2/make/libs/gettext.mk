$(call PKG_INIT_LIB, 0.16.1)
$(PKG)_LIB_VERSION:=8.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=3d9ad24301c6d6b17ec30704a13fe127
$(PKG)_SITE:=@GNU/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/gettext-runtime/intl/.libs/libintl.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libintl.so.$($(PKG)_LIB_VERSION)

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
endif

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-nls
$(PKG)_CONFIGURE_OPTIONS += --disable-java
$(PKG)_CONFIGURE_OPTIONS += --disable-native-java
$(PKG)_CONFIGURE_OPTIONS += --disable-openmp
$(PKG)_CONFIGURE_OPTIONS += --with-included-gettext
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libexpat-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-emacs
$(PKG)_CONFIGURE_OPTIONS += --disable-csharp

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

# We only want libintl
$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GETTEXT_DIR)/gettext-runtime/intl \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(GETTEXT_DIR)/gettext-runtime/intl \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GETTEXT_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgettext* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libintl.h

$(pkg)-uninstall:
	$(RM) $(GETTEXT_TARGET_DIR)/libintl*.so*

$(PKG_FINISH)
