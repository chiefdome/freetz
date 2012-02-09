$(call PKG_INIT_BIN, 5.3.10)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=816259e5ca7d0a7e943e56a3bb32b17f
$(PKG)_SITE:=http://de.php.net/distributions

$(PKG)_BINARY:=$($(PKG)_DIR)/sapi/cgi/php-cgi
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/php-cgi

$(PKG)_STARTLEVEL=90 # before lighttpd

ifeq ($(strip $(FREETZ_PACKAGE_PHP_STATIC)),y)
$(PKG)_STATIC := -all-static
endif

$(PKG)_DEPENDS_ON += pcre
$(PKG)_CONFIGURE_OPTIONS += --with-pcre-regex="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_CURL)),y)
$(PKG)_DEPENDS_ON += curl
$(PKG)_CONFIGURE_OPTIONS += --with-curl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_GD)),y)
$(PKG)_DEPENDS_ON += gd
$(PKG)_CONFIGURE_OPTIONS += --with-gd="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-gd-native-ttf
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_ICONV)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-iconv
$(PKG)_CONFIGURE_OPTIONS += --with-iconv-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
else
$(PKG)_CONFIGURE_ENV += ICONV_IN_LIBC_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

else
$(PKG)_CONFIGURE_OPTIONS += --without-iconv
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_JSON)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-json
else
$(PKG)_CONFIGURE_OPTIONS += --disable-json
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_LIBXML)),y)
$(PKG)_DEPENDS_ON += libxml2
$(PKG)_CONFIGURE_OPTIONS += --with-libxml-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif
$(PKG)_CONFIGURE_OPTIONS += --without-libexpat-dir #we only want libxml-based XML support to be enabled
$(PKG)_XML_SUPPORT:=$(if $(FREETZ_PACKAGE_PHP_WITH_LIBXML),enable,disable)
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-libxml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-dom
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-simplexml
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xmlreader
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_XML_SUPPORT)-xmlwriter

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_PCNTL)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-pcntl
else
$(PKG)_CONFIGURE_OPTIONS += --disable-pcntl
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SESSION)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-session
else
$(PKG)_CONFIGURE_OPTIONS += --disable-session
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SOCKETS)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-sockets
else
$(PKG)_CONFIGURE_OPTIONS += --disable-sockets
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SQLITE2)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite
else
$(PKG)_CONFIGURE_OPTIONS += --without-sqlite
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SQLITE3)),y)
$(PKG)_DEPENDS_ON += sqlite
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite3="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-pdo-sqlite="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
else
$(PKG)_CONFIGURE_OPTIONS += --without-sqlite3
$(PKG)_CONFIGURE_OPTIONS += --without-pdo-sqlite
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_LIBS += "-ldl"
endif

$(PKG)_SYSVIPC_SUPPORT:=$(if $(FREETZ_PACKAGE_PHP_WITH_SYSVIPC),enable,disable)
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_SYSVIPC_SUPPORT)-sysvsem
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_SYSVIPC_SUPPORT)-sysvshm
$(PKG)_CONFIGURE_OPTIONS += --$($(PKG)_SYSVIPC_SUPPORT)-sysvmsg

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
$(PKG)_CONFIGURE_OPTIONS += --with-zlib
$(PKG)_CONFIGURE_OPTIONS += --with-zlib-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_ZIP)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-zip
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_CURL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_GD
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_ICONV
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_JSON
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_LIBXML
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_PCNTL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SESSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SOCKETS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SQLITE2
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SQLITE3
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SYSVIPC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_ZIP
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_ENV += php_cv_sizeof_ssize_t=4
$(PKG)_CONFIGURE_ENV += php_cv_sizeof_ptrdiff_t=4
$(PKG)_CONFIGURE_ENV += ac_cv_c_bigendian_php=$(if $(FREETZ_TARGET_ARCH_BE),yes,no)
$(PKG)_CONFIGURE_ENV += php_cv_sizeof_intmax_t=8
$(PKG)_CONFIGURE_ENV += ac_cv_func_getaddrinfo=yes
$(PKG)_CONFIGURE_ENV += ac_cv_c_stack_direction=-1
$(PKG)_CONFIGURE_ENV += ac_cv_ebcdic=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_atomic_h=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_stdc=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_memcmp_clean=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_utime_null=no
$(PKG)_CONFIGURE_ENV += ac_cv_time_r_type=POSIX
$(PKG)_CONFIGURE_ENV += ac_cv_what_readdir_r=POSIX
$(PKG)_CONFIGURE_ENV += ac_cv_write_stdout=yes
$(PKG)_CONFIGURE_ENV += ac_cv_lib_png_png_write_image=yes
$(PKG)_CONFIGURE_ENV += cookie_io_functions_use_off64_t=yes
$(PKG)_CONFIGURE_ENV += lt_cv_prog_gnu_ldcxx=yes
$(PKG)_CONFIGURE_ENV += lt_cv_path_NM="$(TARGET_NM) -B"

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
ifneq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
endif
$(PKG)_CONFIGURE_OPTIONS += --enable-exif
$(PKG)_CONFIGURE_OPTIONS += --enable-mbstring
$(PKG)_CONFIGURE_OPTIONS += --disable-cli
$(PKG)_CONFIGURE_OPTIONS += --disable-fileinfo
$(PKG)_CONFIGURE_OPTIONS += --disable-phar
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-path=/tmp/flash
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-scan-dir=/tmp/flash/php
$(PKG)_CONFIGURE_OPTIONS += --without-pear

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PHP_DIR) \
		PHP_STATIC="$(PHP_STATIC)" \
		ZEND_EXTRA_LIBS="$(PHP_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PHP_DIR) clean
	$(RM) $(PHP_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(PHP_TARGET_BINARY)

$(PKG_FINISH)
