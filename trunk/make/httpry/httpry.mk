$(call PKG_INIT_BIN, 0.1.5)
$(PKG)_SOURCE:=httpry-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://dumpsterventures.com/jason/httpry
$(PKG)_BINARY:=$($(PKG)_DIR)/httpry
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/httpry
$(PKG)_SOURCE_MD5:=7fbba29eaeec1fd6b25e6fa3a12be25d

$(PKG)_DEPENDS_ON := libpcap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HTTPRY_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDOPTS="-lpcap"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): $($(PKG)_TARGET_DIR)/.exclude

$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	[ "$(FREETZ_PACKAGE_HTTPRY_REMOVE_WEBIF)" == "y" ] \
		&& echo "usr/lib/cgi-bin/httpry.cgi" >> $@ \
		&& echo "usr/lib/cgi-bin/httpry" >> $@ \
		&& echo "etc/default.httpry" >> $@ \
		&& echo "etc/init.d/rc.httpry" >> $@; \
	touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HTTPRY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HTTPRY_TARGET_BINARY)

$(PKG_FINISH)
