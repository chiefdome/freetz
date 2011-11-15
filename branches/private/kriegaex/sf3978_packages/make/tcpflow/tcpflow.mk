$(call PKG_INIT_BIN, 0.21)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=45a5aef6f043312315b7f342afc4a9c5
$(PKG)_SITE:=http://www.circlemud.org/pub/jelson/$(pkg)/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := libpcap

$(PKG)_CONFIGURE_OPTIONS += --host=mipsel-linux
$(PKG)_CONFIGURE_OPTIONS += --target=mipsel-linux
$(PKG)_CONFIGURE_OPTIONS += --with-pcap=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(TCPFLOW_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(TCPFLOW_DIR) clean
	$(RM) $(TCPFLOW_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(TCPFLOW_BINARIES_TARGET_DIR)

$(PKG_FINISH)
