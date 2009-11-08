$(call PKG_INIT_LIB, 1.3.9)
$(PKG)_MAJOR_VERSION:=1
$(PKG)_LIB_VERSION:=0.3.9
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=29dd557f7bd891fc2bfdffcfa081db59
$(PKG)_SITE:=http://apache.mirroring.de/apr/
$(PKG)_MAJOR_LIBNAME=libaprutil-$(APR_UTIL_MAJOR_VERSION)
$(PKG)_LIBNAME=$($(PKG)_MAJOR_LIBNAME).so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)
$(PKG)_INCLUDE_DIR:=/usr/include/apr-util-$(APR_UTIL_MAJOR_VERSION)

$(PKG)_DEPENDS_ON := apr
$(PKG)_DEPENDS_ON += expat
$(PKG)_DEPENDS_ON += sqlite

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += ac_cv_file_dbd_apr_dbd_mysql_c=no
$(PKG)_CONFIGURE_ENV += APR_BUILD_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/apr-$(APR_UTIL_MAJOR_VERSION)/build"

$(PKG)_CONFIGURE_OPTIONS += --with-apr="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-$(APR_UTIL_MAJOR_VERSION)-config"
$(PKG)_CONFIGURE_OPTIONS += --with-expat="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-pgsql=no
$(PKG)_CONFIGURE_OPTIONS += --without-sqlite2
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite3="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --includedir=$(APR_UTIL_INCLUDE_DIR)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(APR_UTIL_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
		$(SUBMAKE) -C $(APR_UTIL_DIR)\
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(APR_UTIL_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/apr-util-$(APR_UTIL_MAJOR_VERSION).pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-$(APR_UTIL_MAJOR_VERSION)-config
	# additional fixes not (yet?) covered by $(PKG_FIX_LIBTOOL_LA)
	sed -i -r $(foreach key,bindir datarootdir datadir,$(call PKG_FIX_LIBTOOL_LA__INT,$(key))) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-$(APR_UTIL_MAJOR_VERSION)-config

	# fixes taken from openwrt
	sed -i -e 's|-[LR][$$]libdir||g' $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-$(APR_UTIL_MAJOR_VERSION)-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(APR_UTIL_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(APR_UTIL_MAJOR_LIBNAME)* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/apr-util-$(APR_UTIL_MAJOR_VERSION).pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-$(APR_UTIL_MAJOR_VERSION)-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/aprutil.exp \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/$(APR_UTIL_INCLUDE_DIR)/

$(pkg)-uninstall:
	$(RM) $(APR_UTIL_TARGET_DIR)/$(APR_UTIL_MAJOR_LIBNAME).so*

$(PKG_FINISH)
