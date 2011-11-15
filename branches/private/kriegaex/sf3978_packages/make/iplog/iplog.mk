$(call PKG_INIT_BIN, 2.2.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=de98dd64018ab10ebe36e481cf00b7db
$(PKG)_SITE:=http://downloads.sourceforge.net/project/ojnk/$(pkg)/2.2.3/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := libpcap

$(PKG)_CONFIGURE_OPTIONS += --without-x
$(PKG)_CONFIGURE_OPTIONS += --disable-maintainer-mode
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap=/usr/lib/freetz
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap-libs=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
$(PKG)_CONFIGURE_OPTIONS += --with-libpcap-includes=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(IPLOG_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(IPLOG_DIR) clean
	$(RM) $(IPLOG_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IPLOG_BINARIES_TARGET_DIR)

$(PKG_FINISH)
