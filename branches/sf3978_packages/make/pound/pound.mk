$(call PKG_INIT_BIN, 2.5)
$(PKG)_SOURCE:=Pound-$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://www.apsis.ch/$(pkg)/
POUND_DIR:=$(SOURCE_DIR)/Pound-$($(PKG)_VERSION)
$(PKG)_SOURCE_MD5:=8a39f5902094619afcda7d12d9d8342c
$(PKG)_BINARIES:=$(pkg) $(pkg)ctl
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

EXTRA_CFLAGS:=-DHAVE_SYSLOG_H=1 -DVERSION=\"2.5\"
$(PKG)_DEPENDS_ON := openssl pcre
$(PKG)_LIBS := -lpcreposix -lssl -lcrypto -ldl -lm -lpthread -lresolv

$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --with-ssl-lib="$(TARGET_TOOLCHAIN_STAGING_DIR)/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-ssl-headers="$(TARGET_TOOLCHAIN_STAGING_DIR)/include/openssl"
$(PKG)_CONFIGURE_OPTIONS += --with-blowfish-headers="$(TARGET_TOOLCHAIN_STAGING_DIR)/include/openssl"
$(PKG)_CONFIGURE_OPTIONS += --with-maxbuf=2048 \
			    --disable-super \
			    --with-t_rsa=3600 \
			    --with-owner=nobody \
			    --with-group=nobody \
			    --with-pcre=yes \
			    --with-thread=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(POUND_DIR) \
		CFLAGS="$(EXTRA_CFLAGS) $(TARGET_CFLAGS)" \
		LIBS="$(POUND_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(POUND_DIR) clean
	$(RM) $(POUND_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(AGET_BINARIES_TARGET_DIR)

$(PKG_FINISH)
