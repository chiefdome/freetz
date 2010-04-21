$(call PKG_INIT_BIN,0.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=cf21e40f289c27bdce831c119eae293e
$(PKG)_SITE:=http://www.hsc.fr/ressources/outils/dns2tcp/download
$(PKG)_BINARY:=$($(PKG)_DIR)/server/dns2tcpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dns2tcpd

$(PKG)_DEPENDS_ON := openssl

ifeq ($(strip $(FREETZ_PACKAGE_DNS2TCP_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_CONFIGURE_OPTIONS += --without-client

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DNS2TCP_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DNS2TCP_DIR) \
		LDFLAGS="$(DNS2TCP_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DNS2TCP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNS2TCP_TARGET_BINARY)

$(PKG_FINISH)
