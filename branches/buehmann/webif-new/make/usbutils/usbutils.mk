$(call PKG_INIT_BIN,0.73)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/linux-usb
$(PKG)_BINARY:=$($(PKG)_DIR)/lsusb
$(PKG)_IDS:=$($(PKG)_DIR)/usb.ids
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/listusb
$(PKG)_TARGET_IDS:=$($(PKG)_DEST_DIR)/usr/share/usb.ids
$(PKG)_SOURCE_MD5:=88978b4ad891f610620b1b8e5e0f43eb

$(PKG)_DEPENDS_ON := libusb

$(PKG)_CONFIGURE_OPTIONS += --disable-zlib

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(USBUTILS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_IDS): $($(PKG)_IDS)
	$(USBUTILS_DIR)/update-usbids.sh
	mkdir -p $(dir $@)
	cp $^ $@

$(pkg):

ifeq ($(strip $(FREETZ_PACKAGE_$(PKG)_IDS)),y)
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_IDS)
else
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(pkg)-clean-ids
endif

$(pkg)-clean-ids:
	@$(RM) $(USBUTILS_TARGET_IDS)

$(pkg)-clean:
	-$(SUBMAKE) -C $(USBUTILS_DIR) clean

$(pkg)-uninstall: $(pkg)-clean-ids
	$(RM) $(USBUTILS_TARGET_BINARY)

$(PKG_FINISH)
