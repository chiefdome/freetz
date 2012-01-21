$(call PKG_INIT_BIN, 0.13.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=9529d75011026b3fcaf185b2fb063881
$(PKG)_SITE:=http://$(pkg).kubs.info/dist/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := $(STDCXXLIB) libpcap pcre glib2 ncurses

$(PKG)_CONFIGURE_OPTIONS += --enable-uia \
			    --disable-multithreaded-resolver \
			    --disable-glibtest \
			    --without-db4

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(JNETTOP_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(JNETTOP_DIR) clean
	$(RM) $(JNETTOP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(JNETTOP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
