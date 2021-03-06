$(call PKG_INIT_BIN, 0.61)
$(PKG)_SOURCE:=PingTunnel-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.cs.uit.no/~daniels/PingTunnel/
$(PKG)_DIR:=$(SOURCE_DIR)/PingTunnel
$(PKG)_BINARY:=$($(PKG)_DIR)/ptunnel
$(PKG)_PKG_VERSION:=
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ptunnel

$(PKG)_DEPENDS_ON := libpcap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(PINGTUNNEL_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DVERSION='\"$(PINGTUNNEL_VERSION)\"'" \
		LDOPTS="-lpthread -lpcap"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) 

$(pkg)-clean:
	-$(MAKE) -C $(PINGTUNNEL_DIR) clean

$(pkg)-uninstall:
	rm -f $(PINGTUNNEL_TARGET_BINARY)
	
$(PKG_FINISH)
