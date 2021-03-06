$(call PKG_INIT_LIB, 1.5.26)
$(PKG)_LIB_VERSION:=3.1.6
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.gnu.org/gnu/libtool
$(PKG)_BINARY:=$($(PKG)_DIR)/libltdl/.libs/libltdl.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libltdl.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libltdl.so.$($(PKG)_LIB_VERSION)

TARGET_CONFIGURE_ENV += GLOBAL_LIBDIR=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBTOOL_DIR)/libltdl

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(LIBTOOL_DIR)/libltdl install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libltdl.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libltdl*.so* $(LIBTOOL_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIBTOOL_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libltdl.*

$(pkg)-uninstall:
	$(RM) $(LIBTOOL_TARGET_DIR)/libltdl*.so*

$(PKG_FINISH)