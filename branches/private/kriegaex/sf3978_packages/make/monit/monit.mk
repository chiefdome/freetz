$(call PKG_INIT_BIN, 5.2.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=862fb7939ad6f73fc0cc82096c2309c7
$(PKG)_SITE:=http://m$(pkg).com/$(pkg)/dist/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := openssl
$(PKG)_LIBS := -lssl -lcrypto

$(PKG)_CONFIGURE_OPTIONS += --host=mipsel-linux 
$(PKG)_CONFIGURE_OPTIONS += --disable-largefile
$(PKG)_CONFIGURE_OPTIONS += --without-largefiles
$(PKG)_CONFIGURE_OPTIONS += --without-pam
$(PKG)_CONFIGURE_OPTIONS += --with-ssl-dir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
$(PKG)_CONFIGURE_OPTIONS += --with-ssl-incl-dir=$(TARGET_TOOLCHAIN_STAGING_DIR)/include/openssl/
$(PKG)_CONFIGURE_OPTIONS += --with-ssl-lib-dir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(MONIT_DIR) \
		  LIBS="$(MONIT_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(MONIT_DIR) clean
	$(RM) $(MONIT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(MONIT_BINARIES_TARGET_DIR)

$(PKG_FINISH)
