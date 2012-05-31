$(call PKG_INIT_BIN, 1.8.3)
$(PKG)_LIB_VERSION:=1.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=7ad8c97c89f77aab7a00317eb7e811e9
$(PKG)_SITE:=http://alioth.debian.org/frs/download.php/3706
$(PKG)_BINARY:=$($(PKG)_DIR)/src/pcscd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/pcscd
$(PKG)_LIB:=$($(PKG)_DIR)/src/.libs/libpcsclite.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_LIB:=$($(PKG)_DEST_LIBDIR)/libpcsclite.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)  

$(PKG)_DEPENDS_ON :=libusb1

$(PKG)_CONFIGURE_OPTIONS += --enable-libusb
$(PKG)_CONFIGURE_OPTIONS += --enable-scf
$(PKG)_CONFIGURE_OPTIONS += --disable-libhal
$(PKG)_CONFIGURE_OPTIONS += --disable-libudev
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
#$(PKG)_CONFIGURE_OPTIONS += --enable-embedded
#$(PKG)_CONFIGURE_OPTIONS += --enable-usbdropdir=/mod/usr/lib/pcsc/drivers


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(PCSC_LITE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)ls 

$($(PKG)_STAGING_BINARY): $($(PKG)_LIB)
	$(SUBMAKE) -C $(PCSC_LITE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcsclite.la


$($(PKG)_TARGET_LIB): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_LIB)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PCSC_LITE_DIR) clean
	$(RM) $(PCSC_LITE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(PCSC_LITE_TARGET_BINARY)

$(PKG_FINISH)
