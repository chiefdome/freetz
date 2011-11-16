$(call PKG_INIT_LIB, 1.6.9)
$(PKG)_LIB_VERSION:=1.6.9
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=fc9db99cfe7c9d7f86da8f53efdbbbd6
$(PKG)_SITE:=http://nlnetlabs.nl/downloads/$(pkg)/
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/lib$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := libpcap 

$(PKG)_CONFIGURE_OPTIONS += --disable-gost
$(PKG)_CONFIGURE_OPTIONS += --without-pyldns
$(PKG)_CONFIGURE_OPTIONS += --disable-ldns-config
$(PKG)_CONFIGURE_OPTIONS += --with-pcap=yes

# Needs openssl >= 1.0.0
#$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"  

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(LDNS_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE1) -C $(LDNS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libldns.a

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(LDNS_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libldns* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/*ldns.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/*ldns \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/man/man?/ldns*

$(pkg)-uninstall:
	$(RM) $(LDNS_TARGET_DIR)/libldns*.so*

$(PKG_FINISH)
