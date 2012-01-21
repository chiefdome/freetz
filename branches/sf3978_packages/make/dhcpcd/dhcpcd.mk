$(call PKG_INIT_BIN, 4.99.7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=f97d2b6f2e54595f5715c7107b54a872
$(PKG)_SITE:=http://roy.marples.name/downloads/$(pkg)/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := $(STDCXXLIB)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(DHCPCD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99 \
		-DTHERE_IS_NO_FORK"  \
		CPPFLAGS="-DINFODIR='\"/var/tmp/flash/dhcpcd\"' \
		-DSYSCONFDIR='\"/var/tmp/flash/dhcpcd\"' \
		-DDBDIR='\"/var/tmp/flash/dhcpcd\"' \
		-DSCRIPT='\"/var/tmp/flash/dhcpcd\"' \
		-D_BSD_SOURCE -D_XOPEN_SOURCE=600" \
		LDADD="-lrt"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(DHCPCD_DIR) clean
	$(RM) $(DHCPCD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DHCPCD_BINARIES_TARGET_DIR)

$(PKG_FINISH)
