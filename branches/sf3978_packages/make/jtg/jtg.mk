$(call PKG_INIT_BIN, v1.95)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=aec37b8c28ef4868fb5b68217385e2c4
$(PKG)_SITE:=http://www.netlab.tkk.fi/~jmanner/$(pkg)

$(PKG)_BINARIES:=$(pkg) $(pkg)_calc jrg jrg_test
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LDFLAGS := -lm

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(JTG_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DLinuxTCP" \
		LDFLAGS="$(TARGET_LDFLAGS) $(JTG_LDFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(JTG_DIR) clean
	$(RM) $(JTG_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(JTG_BINARIES_TARGET_DIR)

$(PKG_FINISH)
