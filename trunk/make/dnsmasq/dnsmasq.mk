$(call PKG_INIT_BIN, 2.56)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b53165c26f9bf9aaaa0e283bfe49a553
$(PKG)_SITE:=http://thekelleys.org.uk/dnsmasq
$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!
$(PKG)_BINARY:=$($(PKG)_DIR)/src/dnsmasq
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dnsmasq

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

ifneq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_COPTS := -DNO_IPV6
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DNSMASQ_DIR) \
		CC="$(TARGET_CC)" \
		COPTS="$(DNSMASQ_COPTS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DNSMASQ_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNSMASQ_TARGET_BINARY)

$(PKG_FINISH)
