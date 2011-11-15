$(call PKG_INIT_BIN, 1.7.4p4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=55d9906535d70a1de347cd3d3550ee87
$(PKG)_SITE:=http://www.sudo.ws/sudo/dist
$(PKG)_BINARIES:=$(pkg) vi$(pkg) $(pkg)replay
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIBS:=lib$(pkg)_noexec.so
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DIR)/.libs/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --without-pam \
			    --disable-pam-session \
			    --with-editor=/bin/vi \
			    --without-lecture \
			    --disable-zlib

$(PKG)_CONFIGURE_ENV += sudo_cv_uid_t_len=10
$(PKG)_CONFIGURE_ENV += sudo_cv_func_unsetenv_void=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(SUDO_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/.libs/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(SUDO_DIR) clean
	$(RM) $(SUDO_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SUDO_BINARIES_TARGET_DIR) $(TRICKLE_LIBS_TARGET_DIR)

$(PKG_FINISH)
