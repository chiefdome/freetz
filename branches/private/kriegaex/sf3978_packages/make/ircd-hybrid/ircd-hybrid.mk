$(call PKG_INIT_BIN, 7.2.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://prdownloads.sourceforge.net/$(pkg)
IRCD-HYBRID_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/ircd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ircd
$(PKG)_SOURCE_MD5:=683fe6e06635d870cfc211f360772f67

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_IRCD_HYBRID_WITH_ZLIB
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_IRCD_HYBRID_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_IRCD_HYBRID_STATIC

ifeq ($(strip $(FREETZ_PACKAGE_IRCD_HYBRID_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON := zlib
endif

ifeq ($(strip $(FREETZ_PACKAGE_IRCD_HYBRID_WITH_SSL)),y)
$(PKG)_DEPENDS_ON := openssl
$(PKG)_LDFLAGS := -lcrypto -lssl -lz -ldl -lresolv
$(PKG)_CONFIGURE_ENV += cf_openssl_basedir="$(TARGET_TOOLCHAIN_STAGING_DIR)"
$(PKG)_CONFIGURE_ENV += cf_openssl_ciphers="${cf_openssl_ciphers}DES/56"
endif

ifeq ($(strip $(FREETZ_PACKAGE_IRCD_HYBRID_STATIC)),y)
$(PKG)_LDFLAGS += -static
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_IRCD_HYBRID_WITH_ZLIB),--enable-zlib=yes,--disable-zlib)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_IRCD_HYBRID_WITH_SSL),--enable-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)",--disable-openssl)
$(PKG)_CONFIGURE_OPTIONS += --enable-syslog='kill squit connect users oper'
$(PKG)_CONFIGURE_OPTIONS += --with-syslog-facility=LOG_LOCAL4
$(PKG)_CONFIGURE_OPTIONS += --enable-epoll
$(PKG)_CONFIGURE_OPTIONS += --disable-shared-modules
$(PKG)_CONFIGURE_OPTIONS += --enable-small-net
$(PKG)_CONFIGURE_OPTIONS += --disable-gline-voting
$(PKG)_CONFIGURE_OPTIONS += --with-nicklen=8
$(PKG)_CONFIGURE_OPTIONS += --with-topiclen=100
$(PKG)_CONFIGURE_OPTIONS += --enable-rtsigio
$(PKG)_CONFIGURE_OPTIONS += --enable-profile

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(IRCD_HYBRID_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS) $(IRCD_HYBRID_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(IRCD_HYBRID_DIR) clean
	$(RM) $(IRCD_HYBRID_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(IRCD_HYBRID_TARGET_BINARY)

$(PKG_FINISH)
