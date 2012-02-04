$(call PKG_INIT_BIN,1.6.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=04e967a3f4108d50cde3b4b0e89e970a
$(PKG)_SITE:=ftp://mama.indstate.edu/linux/tree
$(PKG)_BINARY:=$($(PKG)_DIR)/tree
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tree

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TREE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TREE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TREE_TARGET_BINARY)

$(PKG_FINISH)
