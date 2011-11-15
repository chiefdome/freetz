$(call PKG_INIT_BIN, 1.3.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=69ba36d30722884ea538b70628f1de80
$(PKG)_SITE:=http://downloads.us.xiph.org/releases/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON := tcp_wrappers
$(PKG)_LIBS := -ldl -lm -lpthread

$(PKG)_CONFIGURE_OPTIONS += --with-python=no
$(PKG)_CONFIGURE_OPTIONS += --without-readline
$(PKG)_CONFIGURE_OPTIONS += --with-libwrap
$(PKG)_CONFIGURE_OPTIONS += --with-crypt

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(ICECAST_DIR) \
		LIBS="$(ICECAST_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ICECAST_DIR) clean
	$(RM) $(ICECAST_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(ICECAST_TARGET_BINARY)

$(PKG_FINISH)
