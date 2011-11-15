$(call PKG_INIT_BIN, 1.1-beta6)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_SOURCE_MD5:=275abd75a856b07a798b1f2360088cf5
$(PKG)_SITE:=http://ftp.debian.org/debian/pool/main/n/$(pkg)
$(PKG)_BINARIES:=$(pkg)d $(pkg)cd
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(NSTX_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(NSTX_DIR) clean
	$(RM) $(NSTX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NSTX_BINARIES_TARGET_DIR)

$(PKG_FINISH)
