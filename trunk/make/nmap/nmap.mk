$(call PKG_INIT_BIN, $(strip $(subst ",,$(FREETZ_PACKAGE_NMAP_VERSION))))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5_4.68:=c363d32a00c697d15996fced22072b6c
$(PKG)_SOURCE_MD5_5.51:=0b80d2cb92ace5ebba8095a4c2850275
$(PKG)_SOURCE_MD5 := $($(PKG)_SOURCE_MD5_$($(PKG)_VERSION))
$(PKG)_SITE:=http://nmap.org/dist

$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/nmap
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/nmap
$(PKG)_SERVICES_LIST:=$($(PKG)_DIR)/nmap-services
$(PKG)_TARGET_SERVICES_LIST:=$($(PKG)_DEST_DIR)/usr/share/nmap/nmap-services

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE

$(PKG)_DEPENDS_ON := $(STDCXXLIB) libpcap libdnet
ifeq ($(strip $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA)),y)
$(PKG)_DEPENDS_ON += lua
endif
$(PKG)_CONFIGURE_ENV += ac_cv_header_lua_h=$(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA),yes,no)
ifeq ($(strip $(FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE)),y)
$(PKG)_DEPENDS_ON += pcre
endif

$(PKG)_CONFIGURE_OPTIONS += --with-libpcap="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libdnet="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-liblua=$(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",included)
$(PKG)_CONFIGURE_OPTIONS += --with-libpcre=$(if $(FREETZ_PACKAGE_NMAP_WITH_SHARED_PCRE),"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",included)
# ssl support requires openssl built with ripemd enabled
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --without-zenmap

ifeq ($(strip $(FREETZ_PACKAGE_NMAP_VERSION_5)),y)
$(PKG)_CONFIGURE_OPTIONS += --without-ncat
$(PKG)_CONFIGURE_OPTIONS += --without-ndiff
$(PKG)_CONFIGURE_OPTIONS += --without-nping
else
# FREETZ_PACKAGE_NMAP_VERSION_4
$(PKG)_CONFIGURE_OPTIONS += --with-nmapfe=no
ifeq ($(strip $(FREETZ_PACKAGE_NMAP_WITH_SHARED_LUA)),y)
$(PKG)_CONFIGURE_ENV += LUAINCLUDE=-I"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lua"
endif
endif

# libnbase & libnsock:
# no extra configure options are required in order to use bundled versions of these libraries.

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_SERVICES_LIST): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(NMAP_DIR)
	touch $(NMAP_SERVICES_LIST)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_SERVICES_LIST): $($(PKG)_SERVICES_LIST)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_SERVICES_LIST)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NMAP_DIR) clean
	$(RM) $(NMAP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NMAP_TARGET_BINARY)

$(PKG_FINISH)
