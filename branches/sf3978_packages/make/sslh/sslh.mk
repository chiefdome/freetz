$(call PKG_INIT_BIN, 1.11)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=4ea599f0fa31ae235646e5a200b8f8fb
$(PKG)_SITE:=http://rutschle.net/tech/
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)-fork
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON := tcp_wrappers

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(SSLH_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DLIBWRAP" \
		sslh

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(SSLH_DIR) clean
	$(RM) $(SSLH_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SSLH_TARGET_BINARY)

$(PKG_FINISH)
