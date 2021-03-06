$(call PKG_INIT_BIN, 1.7.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/tinyproxy
$(PKG)_BINARY:=$($(PKG)_DIR)/src/tinyproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tinyproxy
$(PKG)_SOURCE_MD5:=ccacdd9cb093202886b6c7c9e453a804

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_WITH_TRANSPARENT_PROXY
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_WITH_FILTER
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_WITH_UPSTREAM
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TINYPROXY_WITH_SOCKS

$(PKG)_CONFIGURE_ENV += tinyproxy_cv_regex_broken=no

$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TINYPROXY_WITH_TRANSPARENT_PROXY),--enable-transparent-proxy)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TINYPROXY_WITH_FILTER),,--disable-filter)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TINYPROXY_WITH_UPSTREAM),,--disable-upstream)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TINYPROXY_WITH_SOCKS),--enable-socks)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TINYPROXY_DIR) \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CFLAGS="-DNDEBUG $(TARGET_CFLAGS)" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TINYPROXY_DIR) clean
	$(RM) $(TINYPROXY_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(TINYPROXY_TARGET_BINARY)

$(PKG_FINISH)
