$(call PKG_INIT_LIB, 1.0.0)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.tcpdump.org/release/
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=9ad1358c5dec48456405eac197a46d3d

$(PKG)_CONFIGURE_OPTIONS += --with-pcap=linux
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-yydebug
$(PKG)_CONFIGURE_OPTIONS += --with-build-cc="$(HOSTCC)"
$(PKG)_CONFIGURE_OPTIONS += --without-septel
$(PKG)_CONFIGURE_OPTIONS += --without-dag
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBPCAP_DIR) all \
		CCOPT="$(TARGET_CFLAGS)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBPCAP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcap-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIBPCAP_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcap-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pcap*

$(pkg)-uninstall:
	$(RM) $(LIBPCAP_TARGET_DIR)/libpcap*.so*

$(PKG_FINISH)
