$(call PKG_INIT_BIN, 0.6.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=8778b8564c679cf5487b1972ca0b35e4
$(PKG)_SITE:=http://heanet.dl.sourceforge.net/project/$(pkg)/$(pkg)/0.6.6/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-local \
			    --disable-ipv6 \
			    --disable-dccbounce \
			    --disable-ctcp-replies \
			    --disable-dumpstatus \
			    --disable-enduserdebug \
			    --disable-privlog \
			    --disable-uptime \
			    --disable-option-checking \
			    --disable-quicklog

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(MIAU_DIR) \
		LIBS="-lcrypt"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(MIAU_DIR) clean
	$(RM) $(MIAU_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(MIAU_BINARIES_TARGET_DIR)

$(PKG_FINISH)
