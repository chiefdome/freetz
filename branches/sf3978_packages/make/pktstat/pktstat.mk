$(call PKG_INIT_BIN, 1.8.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=56680a1bb256d10ea491dd418eb7f292
$(PKG)_SITE:=http://www.sfr-fresh.com/unix/privat/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := ncurses
$(PKG)_LIBS := -lncurses -lpcap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(PKTSTAT_DIR) \
			    LIBS="$(PKTSTAT_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PKTSTAT_DIR) clean
	 $(RM) $(PKTSTAT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(PKTSTAT_TARGET_BINARY)
	$(RM) $(PKTSTAT_BINARIES_TARGET_DIR)

$(PKG_FINISH)
