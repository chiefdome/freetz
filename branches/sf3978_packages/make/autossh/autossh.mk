$(call PKG_INIT_BIN, 1.4b)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=8f9aa006f6f69e912d3c2f504622d6f7
$(PKG)_SITE:=http://www.harding.motd.ca/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_ENV += ac_cv_lib_nsl_gethostbyname=no
$(PKG)_CONFIGURE_OPTIONS += --with-ssh=/usr/bin/ssh

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(AUTOSSH_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(AUTOSSH_DIR) clean
	$(RM) $(AUTOSSH_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(AUTOSSH_TARGET_BINARY)

$(PKG_FINISH)
