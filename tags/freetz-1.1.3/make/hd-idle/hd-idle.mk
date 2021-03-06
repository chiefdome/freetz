$(call PKG_INIT_BIN, 0.99)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://freetz.falkenhain.info
$(PKG)_SOURCE_FILE:=$($(PKG)_DIR)/hd-idle.c
$(PKG)_BINARY:=$($(PKG)_DIR)/hd-idle
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/hd-idle
$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(HD_IDLE_DIR) \
  	CC="$(TARGET_CC)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(MAKE) -C $(HD_IDLE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HD_IDLE_TARGET_BINARY)

$(PKG_FINISH)
