$(call PKG_INIT_BIN, 2.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=35fa3306f39bfd46d83371da63eec3ad
$(PKG)_SITE:=http://www.earth.li/projectpurple/files/
$(PKG)_BINARIES:=$(pkg) bgp.so icmp.so ipv4.so ipv6.so \
ntp.so rip.so ripng.so tcp.so udp.so
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(SENDIP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -fPIC -fsigned-char -pipe \
		-DSENDIP_LIBS='\"/lib\"' -Wpointer-arith -Wwrite-strings \
		-Wstrict-prototypes -Wnested-externs -Winline -Werror \
		-g -Wcast-align" \
		LDFLAGS="-g  -rdynamic -ldl -lm" \
		LIBCFLAGS="-shared"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(SENDIP_DIR) clean
	$(RM) $(SENDIP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SENDIP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
