$(eval $(call PKG_INIT_BIN, 3.9.6))
$(PKG)_SOURCE:=tcpdump-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.tcpdump.org/release
$(PKG)_BINARY:=$($(PKG)_DIR)/tcpdump
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tcpdump

$(PKG)_CONFIGURE_ENV += BUILD_CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += HOSTCC="$(HOSTCC)"
$(PKG)_CONFIGURE_ENV += td_cv_gubbygetaddrinfo="no"
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
$(PKG)_CONFIGURE_OPTIONS += --without-crypto


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TCPDUMP_DIR) all \
		CCOPT="$(TARGET_CFLAGS)" \
		INCLS="-I." 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

tcpdump: 

tcpdump-precompiled: uclibc libpcap-precompiled tcpdump $($(PKG)_TARGET_BINARY)

tcpdump-clean:
	-$(MAKE) -C $(TCPDUMP_DIR) clean

tcpdump-uninstall:
	rm -f $(TCPDUMP_TARGET_BINARY)

$(PKG_FINISH)
