$(call PKG_INIT_BIN, 3.0.10)
$(PKG)_SOURCE:=privoxy-$($(PKG)_VERSION)-stable-src.tar.gz
$(PKG)_SITE:=@SF/ijbswa
$(PKG)_DIR:=$(SOURCE_DIR)/privoxy-$($(PKG)_VERSION)-stable
$(PKG)_BINARY:=$($(PKG)_DIR)/privoxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/privoxy
$(PKG)_STARTLEVEL=40

$(PKG)_CONFIGURE_PRE_CMDS += autoheader;
$(PKG)_CONFIGURE_PRE_CMDS += autoconf;

ifeq ($(strip $(FREETZ_PACKAGE_PRIVOXY_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON := zlib
endif

$(PKG)_CONFIGURE_ENV += ac_cv_func_setpgrp_void=yes
$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --with-docbook=no
$(PKG)_CONFIGURE_OPTIONS += --disable-pthread
$(PKG)_CONFIGURE_OPTIONS += --disable-stats
$(PKG)_CONFIGURE_OPTIONS += --disable-dynamic-pcre
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_PRIVOXY_WITH_ZLIB),--enable-zlib,)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(PRIVOXY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
	for s in `find $(PRIVOXY_DIR)/templates/ -type f`; do \
		d=$$(basename $$s); \
		egrep -v "^#\ " $$s | egrep -v "^#*$$" >$(PRIVOXY_DEST_DIR)/etc/privoxy/templates/$$d; \
	done
	for s in $(PRIVOXY_DIR)/default.filter $(PRIVOXY_DIR)/default.action $(PRIVOXY_DIR)/standard.action \
		$(PRIVOXY_DIR)/user.action $(PRIVOXY_DIR)/user.filter; do \
		d=$$(basename $$s); \
		egrep -v "^#" $$s | egrep -v "^$$" >$(PRIVOXY_DEST_DIR)/etc/privoxy/$$d; \
	done; true

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PRIVOXY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PRIVOXY_TARGET_BINARY)

$(PKG_FINISH)
