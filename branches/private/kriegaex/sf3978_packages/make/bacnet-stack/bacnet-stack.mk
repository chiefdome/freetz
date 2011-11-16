$(call PKG_INIT_BIN, 0.5.9)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=dbc09cacde7e4436266948700b6268aa
$(PKG)_SITE:=http://downloads.sourceforge.net/project/bacnet/$(pkg)/$(pkg)-0.5.9/
$(PKG)_BINARIES:=bacarf bacawf bacdcc bacepics bacgateway baciamr \
bacinitr bacrd bacrp bacrpm bacserv bacts bacucov bacwh bacwi bacwir \
bacwp mstpcap
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/bin/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(BACNET_STACK_DIR) \
		CC="$(TARGET_CC)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/bin/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(BACNET_STACK_DIR) clean
	$(RM) $(BACNET_STACK_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BACNET_STACK_BINARIES_TARGET_DIR)

$(PKG_FINISH)
