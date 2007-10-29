PACKAGE_LC:=tcpdump
PACKAGE_UC:=TCPDUMP
$(PACKAGE_UC)_VERSION:=3.9.6
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=tcpdump-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://www.tcpdump.org/release
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/tcpdump
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_DIR)/usr/bin/tcpdump

$(PACKAGE_UC)_CONFIGURE_ENV += BUILD_CC="$(TARGET_CC)"
$(PACKAGE_UC)_CONFIGURE_ENV += HOSTCC="$(HOSTCC)"
$(PACKAGE_UC)_CONFIGURE_ENV += ac_cv_linux_vers=2
$(PACKAGE_UC)_CONFIGURE_ENV += td_cv_gubbygetaddrinfo="no"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-ipv6
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-crypto


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TCPDUMP_DIR) all \
		CCOPT="$(TARGET_CFLAGS)" \
		INCLS="-I." 

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

tcpdump: 

tcpdump-precompiled: uclibc libpcap-precompiled tcpdump $($(PACKAGE_UC)_TARGET_BINARY)

tcpdump-clean:
	-$(MAKE) -C $(TCPDUMP_DIR) clean

tcpdump-uninstall:
	rm -f $(TCPDUMP_TARGET_BINARY)

$(PACKAGE_FINI)
