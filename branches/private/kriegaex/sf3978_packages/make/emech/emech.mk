$(call PKG_INIT_BIN, 3.0.99p3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=40c0bde6b7c9964584445da1f6d34b39
$(PKG)_SITE:=http://www.energymech.net/files/
$(PKG)_BINARIES:=energymech
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(EMECH_DIR) \
		    CC="$(TARGET_CC)" \
		    CFLAGS="$(TARGET_CFLAGS) -D__BSD_SOURCE"
	
$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(EMECH_DIR) clean
	$(RM) $(EMECH_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(EMECH_BINARIES_TARGET_DIR)

$(PKG_FINISH)
