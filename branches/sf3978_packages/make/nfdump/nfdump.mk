$(call PKG_INIT_BIN, 1.6.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=480e008be8ba038ce776e42af441d664
$(PKG)_SITE:=http://downloads.sourceforge.net/project/$(pkg)/stable/$(pkg)-$($(PKG)_VERSION)/

$(PKG)_BINARIES:=nfdump nfcapd nfreplay nfexpire
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/bin/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NFDUMP_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/bin/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NFDUMP_DIR) clean
	$(RM) $(NFDUMP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NFDUMP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
