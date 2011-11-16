$(call PKG_INIT_LIB, 1.22)
$(PKG)_LIB_VERSION:=11.6.5
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=893a1df0cf3b28b72d248382eaeaca71
$(PKG)_SITE:=http://ftp.gnu.org/gnu/$(pkg)/
$(PKG)_BINARY:=$($(PKG)_DIR)/lib/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-html

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBIDN_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBIDN_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libidn.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libidn.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBIDN_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libidn* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/idn* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libidn.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/Libidn.dll \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/info/libidn* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/man/man3/idna*

$(pkg)-uninstall:
	$(RM) $(LIBIDN_TARGET_DIR)/libidn*.so*

$(PKG_FINISH)
