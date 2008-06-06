$(call PKG_INIT_BIN, 1.7.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/tinyproxy
$(PKG)_BINARY:=$($(PKG)_DIR)/src/tinyproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tinyproxy
$(PKG)_STARTLEVEL=40

$(PKG)_CONFIG_SUBOPTS += FREETZ_COMPILE_TINYPROXY_WITH_TRANSPARENT_PROXY
$(PKG)_CONFIG_SUBOPTS += FREETZ_COMPILE_TINYPROXY_WITH_FILTER
$(PKG)_CONFIG_SUBOPTS += FREETZ_COMPILE_TINYPROXY_WITH_UPSTREAM
$(PKG)_CONFIG_SUBOPTS += FREETZ_COMPILE_TINYPROXY_WITH_SOCKS

$(PKG)_CONFIGURE_ENV += tinyproxy_cv_regex_broken=no

$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_COMPILE_TINYPROXY_WITH_TRANSPARENT_PROXY),--enable-transparent-proxy)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_COMPILE_TINYPROXY_WITH_FILTER),,--disable-filter)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_COMPILE_TINYPROXY_WITH_UPSTREAM),,--disable-upstream)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_COMPILE_TINYPROXY_WITH_SOCKS),--enable-socks)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		CFLAGS="-DNDEBUG $(TARGET_CFLAGS)" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		-C $(TINYPROXY_DIR) 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(TINYPROXY_DIR) clean
	$(RM) $(TINYPROXY_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(TINYPROXY_TARGET_BINARY)

$(PKG_FINISH)
