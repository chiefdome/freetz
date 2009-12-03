$(call PKG_INIT_BIN, 0.8.14)
$(PKG)_SOURCE:=irssi-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://irssi.org/files
$(PKG)_BINARY:=$($(PKG)_DIR)/src/fe-text/irssi
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/irssi
$(PKG)_SOURCE_MD5:=7d9437f53209a61af4fe4c9c5528ffa7

ifeq ($(strip $(FREETZ_PACKAGE_IRSSI_WITH_BOT)),y)
$(PKG)_BOT_BINARY:=$($(PKG)_DIR)/src/fe-none/botti
$(PKG)_BOT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/botti
endif

ifeq ($(strip $(FREETZ_PACKAGE_IRSSI_WITH_PROXY)),y)
$(PKG)_LIBPROXY_BINARY:=$($(PKG)_DIR)/src/irc/proxy/.libs/libirc_proxy.so
$(PKG)_LIBPROXY_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/irssi/modules/libirc_proxy.so
endif

$(PKG)_DEPENDS_ON := glib2 ncurses

ifeq ($(strip $(FREETZ_PACKAGE_IRSSI_WITH_OPENSSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_IRSSI_WITH_BOT
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_IRSSI_WITH_PROXY
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_IRSSI_WITH_OPENSSL

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --with-textui
$(PKG)_CONFIGURE_OPTIONS += --with-perl=no
$(PKG)_CONFIGURE_OPTIONS += --disable-glibtest
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_IRSSI_WITH_BOT),--with-bot,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_IRSSI_WITH_PROXY),--with-proxy,)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_IRSSI_WITH_OPENSSL),,--disable-ssl)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IRSSI_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LD="$(TARGET_CC)" \
		LIBS=-ldl

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

ifeq ($(strip $(FREETZ_PACKAGE_IRSSI_WITH_BOT)),y)
$($(PKG)_BOT_TARGET_BINARY): $($(PKG)_BOT_BINARY)
	$(INSTALL_BINARY_STRIP)
endif

ifeq ($(strip $(FREETZ_PACKAGE_IRSSI_WITH_PROXY)),y)
$($(PKG)_LIBPROXY_TARGET_BINARY): $($(PKG)_LIBPROXY_BINARY)
	$(INSTALL_LIBRARY_STRIP)
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_BOT_TARGET_BINARY) $($(PKG)_LIBPROXY_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IRSSI_DIR) clean

$(pkg)-uninstall:
	$(RM) $(IRSSI_TARGET_BINARY)

$(PKG_FINISH)
