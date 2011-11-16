$(call PKG_INIT_LIB, 1.6.13)
$(PKG)_LIB_VERSION:=6.1.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=71476b1781ad179bfc9bead640be5f54
$(PKG)_SITE:=http://downloads.sourceforge.net/project/pupnp/pupnp/libUPnP%201.6.13/

$(PKG)_BINARY:=$($(PKG)_DIR)/upnp/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_BINARY1:=$($(PKG)_DIR)/ixml/.libs/libixml.so.2.0.6
$(PKG)_STAGING_BINARY1:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libixml.so.2.0.6
$(PKG)_TARGET_BINARY1:=$($(PKG)_TARGET_DIR)/libixml.so.2.0.6

$(PKG)_BINARY2:=$($(PKG)_DIR)/threadutil/.libs/libthreadutil.so.6.0.0
$(PKG)_STAGING_BINARY2:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libthreadutil.so.6.0.0
$(PKG)_TARGET_BINARY2:=$($(PKG)_TARGET_DIR)/libthreadutil.so.6.0.0

$(PKG)_CONFIGURE_OPTIONS += --disable-notification_reordering
$(PKG)_CONFIGURE_OPTIONS += --disable-blocking_tcp_connections
$(PKG)_CONFIGURE_OPTIONS += --disable-samples
$(PKG)_CONFIGURE_OPTIONS += --without-documentation

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBUPNP_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBUPNP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libupnp.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libupnp.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libixml.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libthreadutil.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_TARGET_BINARY1): $($(PKG)_STAGING_BINARY1)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_TARGET_BINARY2): $($(PKG)_STAGING_BINARY2)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY) $($(PKG)_STAGING_BINARY1) $($(PKG)_STAGING_BINARY2)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_BINARY1) $($(PKG)_TARGET_BINARY2)

$(pkg)-clean:
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libupnp* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libupnp \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libupnp.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/doc/libupnp \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libixml* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libixml \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libixml.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/doc/libixml \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libthreadutil* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libthreadutil \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libthreadutil.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/doc/libthreadutil

$(pkg)-uninstall:
	$(RM) $(LIBUPNP_DEST_LIB)/libupnp*.so*
	$(RM) $(LIBUPNP_DEST_LIB)/libixml*.so*
	$(RM) $(LIBUPNP_DEST_LIB)/libthreadutil*.so*

$(PKG_FINISH)
