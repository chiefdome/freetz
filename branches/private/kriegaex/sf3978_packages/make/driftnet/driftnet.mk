$(call PKG_INIT_BIN, 0.1.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=8e11d77770452f97bb3c23f510489815
$(PKG)_SITE:=http://www.ex-parrot.com/~chris/$(pkg)/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := libpcap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(DRIFTNET_DIR) \
		CC="$(HOSTCC)" \
		LINK="$(HOSTCC) -o endian -lc" \
		CFLAGS="" \
		endian
	$(SUBMAKE1) -C $(DRIFTNET_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -g -DNO_DISPLAY_WINDOW  \
		-DDRIFTNET_VERSION='\"$(VERSION)\"' -D_BSD_SOURCE" \
		LDFLAGS="-g" \
		LDLIBS="-lpcap -lpthread"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(DRIFTNET_DIR) clean
	$(RM) $(DRIFTNET_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DRIFTNET_BINARIES_TARGET_DIR)

$(PKG_FINISH)
