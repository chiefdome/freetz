$(call PKG_INIT_BIN, 2.9.4)
$(PKG)_SOURCE:=$(pkg)$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.uni-frankfurt.de/pub/Mirrors2/gentoo.org/distfiles/
$(PKG)_BINARY:=$(SOURCE_DIR)/$(pkg)$($(PKG)_VERSION)/$(pkg)
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)$($(PKG)_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_SOURCE_MD5:=190486d2346415e30f6381377e82eb3b

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := libnet
$(PKG)_CONFIGURE_OPTIONS += --without-ssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(BNC_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(BNC_DIR) clean
	$(RM) $(BNC_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(BNC_TARGET_BINARY)

$(PKG_FINISH)
