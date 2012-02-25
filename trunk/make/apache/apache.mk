$(call PKG_INIT_BIN, 1.3.42)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=8545eeea90f848fe1d15298328a217f0
$(PKG)_SITE:=@APACHE/httpd
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)_$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_APACHE_COMPILEINMODS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_APACHE_STATIC

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += LD_SHLIB="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += LDFLAGS="$(if $(FREETZ_PACKAGE_APACHE_STATIC),-static)"
$(PKG)_CONFIGURE_ENV += EXTRA_LIBS="-ldl"
$(PKG)_CONFIGURE_OPTIONS += --target=$(pkg)
$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr/apache
$(PKG)_CONFIGURE_OPTIONS += --bindir=/usr/sbin
$(PKG)_CONFIGURE_OPTIONS += --sbindir=/usr/sbin
$(PKG)_CONFIGURE_OPTIONS += --localstatedir=/var/apache
$(PKG)_CONFIGURE_OPTIONS += --runtimedir=/var/apache/logs
$(PKG)_CONFIGURE_OPTIONS += --logfiledir=/var/apache/logs
$(PKG)_CONFIGURE_OPTIONS += --proxycachedir=/var/apache/proxy
$(PKG)_CONFIGURE_OPTIONS += --enable-module=most
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_APACHE_COMPILEINMODS),--disable-shared=all,--enable-shared=max)

$(PKG)_MAKE_FLAGS += AR="$(TARGET_AR)"
$(PKG)_MAKE_FLAGS += RANLIB="$(TARGET_RANLIB)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(APACHE_DIR) \
		$(APACHE_MAKE_FLAGS)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE1) -C $(APACHE_DIR) install \
		root="$(FREETZ_BASE_DIR)/$(APACHE_DEST_DIR)"
	$(RM) -r \
		$(APACHE_DEST_DIR)/{usr/sbin,var} \
		$(APACHE_DEST_DIR)/usr/apache/{cgi-bin/*,conf/*.default,htdocs,icons/README*,include,man,libexec/httpd.exp}
	-$(TARGET_STRIP) $(APACHE_DEST_DIR)/usr/apache/libexec/*.so
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $(APACHE_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(APACHE_DIR) clean
	$(RM) $(APACHE_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(APACHE_TARGET_BINARY)

$(PKG_FINISH)
