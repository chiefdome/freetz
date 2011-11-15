$(call PKG_INIT_BIN, 1.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=f2826439c6e0750d50a65721460676e8
$(PKG)_SITE:=http://freeworld.thc.org/releases/
$(PKG)_BINARIES:=alive6 covert_send6 covert_send6d denial6 detect-new-ip6 \
dnsdict6 dos-new-ip6 exploit6 fake_advertise6 fake_mipv6 \
fake_mld26 fake_mld6 fake_mldrouter6 fake_router6 \
flood_advertise6 flood_router6 fuzz_ip6 implementation6 \
implementation6d parasite6 redir6 rsmurf6 sendpees6 \
smurf6 thcping6 toobig6 trace6
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := $(STDCXXLIB) libpcap openssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(THC_IPV6_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(THC_IPV6_DIR) clean
	$(RM) $(THC_IPV6_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(THC_IPV6_BINARIES_TARGET_DIR)

$(PKG_FINISH)
