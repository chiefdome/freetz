$(call PKG_INIT_BIN, 0.4.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/checkmaild
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/checkmaild
$(PKG)_SOURCE_MD5:=c82af968a87cf3c734495a76c6e628f6

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) CROSS="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-lpthread" \
		-C $(CHECKMAILD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CHECKMAILD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CHECKMAILD_TARGET_BINARY)

$(PKG_FINISH)
