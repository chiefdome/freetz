$(call PKG_INIT_BIN,0.1.7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/usbip
$(PKG)_SOURCE_MD5:=d1094b6d4449787864f8be001639232c

$(PKG)_BINARY:=$($(PKG)_DIR)/src/cmd/usbipd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/usbipd

# kernel 2.6.28 has stock usbip modules
$(PKG)_MOD_BINARY:=$($(PKG)_DIR)/drivers/2.6.21/usbip.ko
$(PKG)_MOD_TARGET_DIR:=$(KERNEL_MODULES_DIR)/drivers/usb/usbip
$(PKG)_MOD_TARGET_BINARY:=$($(PKG)_MOD_TARGET_DIR)/usbip.ko

$(PKG)_DEPENDS_ON := kernel sysfsutils glib2

$(PKG)_CONFIGURE_PRE_CMDS += cd src ;
$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh ;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(USBIP_DIR)/src \
		CPPFLAGS="-std=gnu99 -fgnu89-inline"

$($(PKG)_MOD_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(USBIP_DIR)/drivers/2.6.21 \
		KSOURCE="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)" \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(USBIP_DEST_DIR)/usr/bin
	mkdir -p $(USBIP_DEST_DIR)/usr/share/usbip
	cp $(USBIP_DIR)/src/cmd/usbipd $(USBIP_DEST_DIR)/usr/bin
	cp $(USBIP_DIR)/src/cmd/bind_driver $(USBIP_DEST_DIR)/usr/bin
	cp $(USBIP_DIR)/src/usb.ids $(USBIP_DEST_DIR)/usr/share/usbip/usb.ids
	$(TARGET_STRIP) $(USBIP_DEST_USR_BIN)/usbipd \
		$(USBIP_DEST_USR_BIN)/bind_driver

$($(PKG)_MOD_TARGET_BINARY): $($(PKG)_MOD_BINARY)
	mkdir -p $(dir $@)
	cp $(USBIP_DIR)/drivers/2.6.21/usbip.ko $(dir $@)
	cp $(USBIP_DIR)/drivers/2.6.21/usbip_common_mod.ko $(dir $@)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) \
	$(if $(or $(FREETZ_KERNEL_VERSION_2_6_28),$(FREETZ_KERNEL_VERSION_2_6_32)),,$($(PKG)_MOD_TARGET_BINARY))

$(pkg)-clean:
	-$(SUBMAKE) -C $(USBIP_DIR)/src clean

$(pkg)-uninstall:
	$(RM) $(USBIP_DEST_DIR)/usr/bin/usbipd
	$(RM) $(USBIP_DEST_DIR)/usr/bin/bind_driver
	$(RM) $(USBIP_DEST_DIR)/usr/share/usbip/usb.ids

$(PKG_FINISH)
