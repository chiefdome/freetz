$(call PKG_INIT_BIN, 0.5.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=84222e53ca20ff805a16c769016ef671
$(PKG)_SITE:=http://downloads.sourceforge.net/project/zeroconf/$(pkg)/0.5.3/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/server/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_ENV += ac_cv_lib_resolv___dn_expand=no

$(PKG)_CONFIGURE_OPTIONS += --without-perl \
			    --enable-netlink

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(TMDNS_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/server/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(TMDNS_DIR) clean
	$(RM) $(TMDNS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(TMDNS_BINARIES_TARGET_DIR)

$(PKG_FINISH)
