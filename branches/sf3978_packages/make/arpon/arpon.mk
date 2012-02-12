$(call PKG_INIT_BIN, 2.7)
$(PKG)_SOURCE:=ArpON-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=3c3230f6852b9ffd5618a35c2f25221c
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_DIR:=$(SOURCE_DIR)/ArpON-$($(PKG)_VERSION)

$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$(PKG)_DEPENDS_ON := libnet libpcap libdnet

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(ARPON_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DLINUX -D_GNU_SOURCE \
		-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(ARPON_DIR) clean
	$(RM) $(ARPON_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(ARPON_BINARIES_TARGET_DIR)

$(PKG_FINISH)
