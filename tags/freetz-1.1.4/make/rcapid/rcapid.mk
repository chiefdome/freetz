$(call PKG_INIT_BIN, 0.1)
$(PKG)_SOURCE:=rcapid-cm.tar.gz
$(PKG)_SITE:=ftp://ftp.melware.de/capi-utils
$(PKG)_DIR:=$(SOURCE_DIR)/rcapid-cm
$(PKG)_BINARY:=$($(PKG)_DIR)/rcapid
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/rcapid
$(PKG)_STARTLEVEL=40

$(PKG)_DEPENDS_ON := libcapi

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	$(MAKE) -C $(RCAPID_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(RCAPID_DIR) clean

$(pkg)-uninstall:
	$(RM) $(RCAPID_TARGET_BINARY)

$(PKG_FINISH)