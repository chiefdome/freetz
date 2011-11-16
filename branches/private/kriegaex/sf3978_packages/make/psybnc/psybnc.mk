$(call PKG_INIT_BIN, 2.3.2-9)
$(PKG)_SOURCE:=psyBNC-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.psybnc.at/download/beta
$(PKG)_DIR:=$(SOURCE_DIR)/psybnc
$(PKG)_BINARY:=$(SOURCE_DIR)/psybnc/psybnc
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/psybnc
$(PKG)_SOURCE_MD5:=c2757cdf2cab668eb374a22abecc5572

$(PKG)_DEPENDS_ON := openssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(PSYBNC_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(if $(FREETZ_TARGET_ARCH_BE),-DBIGENDIAN,)" 
		

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)	  

$(pkg)-clean:
	-$(SUBMAKE1) -C $(PSYBNC_DIR) clean
	$(RM) $(PSYBNC_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(PSYBNC_TARGET_BINARY)
