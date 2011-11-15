$(call PKG_INIT_BIN, 2.2a)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=8b49cf9e06c8e0a603dd2b2884b804ab
$(PKG)_SITE:=http://downloads.sourceforge.net/project/$(pkg)/$(pkg)/$(pkg)-2.2a/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += ac_cv_search_crypt=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_gethostbyaddr=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_sigemptyset=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_crypt=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_getpass=yes

$(PKG)_CONFIGURE_OPTIONS += --enable-local
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(MUH_DIR) \
		LIBS="-lcrypt"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(MUH_DIR) clean
	$(RM) $(MUH_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(MUH_BINARIES_TARGET_DIR)

$(PKG_FINISH)
