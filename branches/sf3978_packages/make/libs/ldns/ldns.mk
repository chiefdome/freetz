$(call PKG_INIT_LIB, 1.6.11)
$(PKG)_LIB_VERSION:=1.6.11
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c55b592a679672281712c457fbb41eb5
$(PKG)_SITE:=http://nlnetlabs.nl/downloads/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/lib$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# remove optimization & debug flags
$(PKG)_CONFIGURE_PRE_CMDS += $(foreach flag,-O[0-9] -g,$(SED) -i -r -e 's,(C(XX)?FLAGS="[^"]*)$(flag)(( [^"]*)?"),\1\3,g' ./configure;)

$(PKG)_CONFIGURE_OPTIONS += --disable-ldns-config
$(PKG)_CONFIGURE_OPTIONS += --disable-gost
$(PKG)_CONFIGURE_OPTIONS += --without-pyldns
$(PKG)_CONFIGURE_OPTIONS += --without-pyldnsx
$(PKG)_CONFIGURE_OPTIONS += --without-ssl
# sha2 requires ssl to be enabled
$(PKG)_CONFIGURE_OPTIONS += --disable-sha2

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LDNS_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LDNS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-h install-lib
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libldns.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LDNS_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libldns* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ldns

$(pkg)-uninstall:
	$(RM) $(LDNS_TARGET_DIR)/libldns*.so*

$(PKG_FINISH)
