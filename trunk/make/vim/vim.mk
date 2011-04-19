$(call PKG_INIT_BIN, 7.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=ftp://ftp.vim.org/pub/vim/unix
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)71
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_SOURCE_MD5:=44c6b4914f38d6f9aa959640b89da329

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_CONFIGURE_OPTIONS += --disable-gui
$(PKG)_CONFIGURE_OPTIONS += --disable-gtktest
$(PKG)_CONFIGURE_OPTIONS += --disable-xim
ifeq ($(strip $(FREETZ_PACKAGE_VIM_HUGE)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-features=huge
else
ifeq ($(strip $(FREETZ_PACKAGE_VIM_NORMAL)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-features=normal
else
$(PKG)_CONFIGURE_OPTIONS += --with-features=tiny
endif
endif
$(PKG)_CONFIGURE_OPTIONS += --without-x
$(PKG)_CONFIGURE_OPTIONS += --disable-multibyte
$(PKG)_CONFIGURE_OPTIONS += --disable-netbeans
$(PKG)_CONFIGURE_OPTIONS += --disable-gpm
$(PKG)_CONFIGURE_OPTIONS += --with-tlib=ncurses

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) $(VIM_MAKE_OPTIONS) -C $(VIM_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(VIM_DIR) clean
	$(RM) $(VIM_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(VIM_TARGET_BINARY)

$(PKG_FINISH)
