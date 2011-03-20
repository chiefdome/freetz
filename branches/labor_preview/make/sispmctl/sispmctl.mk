$(call PKG_INIT_BIN, 2.7)
$(PKG)_SOURCE:=sispmctl-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=2457f76cd129f880634f3381be0aeb76
$(PKG)_SITE:=@SF/sispmctl

$(PKG)_BINARY:=$($(PKG)_DIR)/src/sispmctl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sispmctl

$(PKG)_DEPENDS_ON := libusb

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_SISPMCTL_WEB),--with-webdir=/usr/share/sispmctl,--enable-webless)

$(PKG)_REBUILD_SUBOPTS += FREETZ_SISPMCTL_WEB

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SISPMCTL_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
ifeq ($(strip $(FREETZ_SISPMCTL_WEB)),y)
	mkdir -p $(SISPMCTL_DEST_DIR)/usr/share/sispmctl
	cp $(SISPMCTL_DIR)/src/web1/* $(SISPMCTL_DEST_DIR)/usr/share/sispmctl
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SISPMCTL_DIR) clean
	$(RM) $(SISPMCTL_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(SISPMCTL_TARGET_BINARY)

$(PKG_FINISH)
