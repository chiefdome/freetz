$(call PKG_INIT_BIN, 0.2.0.31)
$(PKG)_SOURCE:=tor-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.torproject.org/dist
$(PKG)_BINARY:=$($(PKG)_DIR)/src/or/tor
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tor
$(PKG)_STARTLEVEL=40

$(PKG)_DEPENDS_ON := zlib openssl libevent

$(PKG)_CONFIGURE_ENV += CROSS_COMPILE="yes"
$(PKG)_CONFIGURE_ENV += ac_cv_libevent_linker_option='(none)'
$(PKG)_CONFIGURE_ENV += ac_cv_openssl_linker_option='(none)'
$(PKG)_CONFIGURE_ENV += ac_cv_libevent_normal=yes
$(PKG)_CONFIGURE_ENV += tor_cv_null_is_zero=yes
$(PKG)_CONFIGURE_ENV += tor_cv_unaligned_ok=yes
$(PKG)_CONFIGURE_ENV += tor_cv_time_t_signed=yes

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --with-ssl-dir="$(TARGET_MAKE_PATH)/../usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-libevent-dir="$(TARGET_MAKE_PATH)/../usr/lib"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) CFLAGS="$(TARGET_CFLAGS)" -C $(TOR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(TOR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TOR_TARGET_BINARY)

$(PKG_FINISH)
