$(call PKG_INIT_BIN, 3.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=e1646c8d25478432252be0e8f2eab640
$(PKG)_SITE:=http://pwhois.org/get
$(PKG)_BINARIES:=$(pkg) whob
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_OPTIONS += --with-pcap="$(TARGET_TOOLCHAIN_STAGING_DIR)/include/pcap"

$(PKG)_DEPENDS_ON := libpcap
$(PKG)_LIBS := -lpcap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(LFT_DIR) \
		LIBS="$(LFT_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LFT_DIR) clean
	$(RM) $(LFT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(LFT_BINARIES_TARGET_DIR)

$(PKG_FINISH)
