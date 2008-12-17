$(call PKG_INIT_BIN, 2.8.10)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/hplip
$(PKG)_LIB_IP_VERSION=0.0.1
$(PKG)_LIB_IP_BINARY:=$($(PKG)_DIR)/.libs/libhpip.so.$($(PKG)_LIB_IP_VERSION)
$(PKG)_LIB_IP_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpip.so.$($(PKG)_LIB_IP_VERSION)
$(PKG)_LIB_IP_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/libhpip.so.$($(PKG)_LIB_IP_VERSION)
$(PKG)_LIB_MUD_VERSION=0.0.4
$(PKG)_LIB_MUD_BINARY:=$($(PKG)_DIR)/.libs/libhpmud.so.$($(PKG)_LIB_MUD_VERSION)
$(PKG)_LIB_MUD_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpmud.so.$($(PKG)_LIB_MUD_VERSION)
$(PKG)_LIB_MUD_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/libhpmud.so.$($(PKG)_LIB_MUD_VERSION)
$(PKG)_LIB_HPAIO_VERSION=1.0.0
$(PKG)_LIB_HPAIO_BINARY:=$($(PKG)_DIR)/.libs/libsane-hpaio.so.$($(PKG)_LIB_HPAIO_VERSION)
$(PKG)_LIB_HPAIO_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sane/libsane-hpaio.so.$($(PKG)_LIB_HPAIO_VERSION)
$(PKG)_LIB_HPAIO_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/sane/libsane-hpaio.so.$($(PKG)_LIB_HPAIO_VERSION)


$(PKG)_DEPENDS_ON := sane-backends

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS += --disable-doc-build
$(PKG)_CONFIGURE_OPTIONS += --disable-network-build
$(PKG)_CONFIGURE_OPTIONS += --disable-pp-build
$(PKG)_CONFIGURE_OPTIONS += --disable-gui-build
$(PKG)_CONFIGURE_OPTIONS += --disable-fax-build
$(PKG)_CONFIGURE_OPTIONS += --disable-dbus-build
$(PKG)_CONFIGURE_OPTIONS += --disable-foomatic-drv-install
$(PKG)_CONFIGURE_OPTIONS += --disable-foomatic-rip-hplip-install

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_IP_BINARY) \
	$($(PKG)_LIB_MUD_BINARY) \
	$($(PKG)_LIB_HPAIO_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(HPLIP_DIR)

$($(PKG)_LIB_IP_STAGING_BINARY) \
	$($(PKG)_LIB_MUD_STAGING_BINARY) \
	$($(PKG)_LIB_HPAIO_STAGING_BINARY): $($(PKG)_LIB_IP_BINARY) \
						$($(PKG)_LIB_MUD_BINARY) \
						$($(PKG)_LIB_HPAIO_BINARY)
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(HPLIP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpip.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpmud.la
	cp $(HPLIP_DIR)/io/hpmud/hpmud.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include

$($(PKG)_LIB_IP_TARGET_BINARY): $($(PKG)_LIB_IP_STAGING_BINARY)
	mkdir -p $(HPLIP_DEST_DIR)/usr/lib
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpip.so* $(HPLIP_DEST_DIR)/usr/lib
	$(TARGET_STRIP) $@

$($(PKG)_LIB_MUD_TARGET_BINARY): $($(PKG)_LIB_MUD_STAGING_BINARY)
	mkdir -p $(HPLIP_DEST_DIR)/usr/lib
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhpmud.so* $(HPLIP_DEST_DIR)/usr/lib
	$(TARGET_STRIP) $@

$($(PKG)_LIB_HPAIO_TARGET_BINARY): $($(PKG)_LIB_HPAIO_STAGING_BINARY)
	mkdir -p $(HPLIP_DEST_DIR)/usr/lib/sane
	mkdir -p $(HPLIP_DEST_DIR)/etc
	mkdir -p $(HPLIP_DEST_DIR)/usr/share
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sane/libsane-hpaio.so* $(HPLIP_DEST_DIR)/usr/lib/sane
	cp -R $(TARGET_TOOLCHAIN_STAGING_DIR)/etc/sane.d $(HPLIP_DEST_DIR)/etc
	cp -R $(TARGET_TOOLCHAIN_STAGING_DIR)/etc/default.hplip $(HPLIP_DEST_DIR)/etc
	cp -R $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/hplip $(HPLIP_DEST_DIR)/usr/share
	$(TARGET_STRIP) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIB_IP_TARGET_BINARY) \
			$($(PKG)_LIB_MUD_TARGET_BINARY) \
			$($(PKG)_LIB_HPAIO_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(HPLIP_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhp* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/sane/libsane-hpaio* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/hpmud.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/hplip \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/etc/default.hplip \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/etc/sane.d

$(PKG_FINISH)
