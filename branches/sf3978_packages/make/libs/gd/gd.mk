$(call PKG_INIT_LIB, 2.0.35)
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=gd-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=6c6c3dbb7bf079e0bb5fbbfd3bb8a71c
$(PKG)_SITE:=http://www.libgd.org/releases

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgd.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := jpeg libpng freetype

# fix libgd packaging errors (configure.ac has a later date than configure & aclocal.m4 has a later date than config.hin)
# prevents configure & config.hin from being regenerated, which in turn allows PKG_PREVENT_RPATH_HARDCODING macro to do its job
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac ./aclocal.m4; touch ./config.hin ./configure;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --with-x=no
$(PKG)_CONFIGURE_OPTIONS += --with-xpm=no
$(PKG)_CONFIGURE_OPTIONS += --with-fontconfig=no
#$(PKG)_CONFIGURE_OPTIONS += --disable-pthreads?

$(call REPLACE_LIBTOOL)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GD_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(GD_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/gdlib-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GD_DIR) clean
	$(RM) $(LIBGD_FREETZ_CONFIG_FILE)
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/gd \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/gdlib-config

$(pkg)-uninstall:
	$(RM) $(LIBGD_TARGET_DIR)/libgd*.so*

$(PKG_FINISH)
