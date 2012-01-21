$(call PKG_INIT_BIN, 3.0.714)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=eef385fadc8dbb611d3d4c4d8fa94817
$(PKG)_SITE:=http://dmr.ath.cx/net/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON := libpcap zlib
$(PKG)_CONFIGURE_OPTIONS += --with-chroot-dir=/var/empty

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(DARKSTAT_DIR) \
		CC="$(HOSTCC)" \
		LINK="$(HOSTCC) -o c-ify -lc" \
		CFLAGS="" \
		c-ify
		$(SUBMAKE1) -C $(DARKSTAT_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99 -I./"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(DARKSTAT_DIR) clean
	$(RM) $(DARKSTAT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DARKSTAT_TARGET_BINARY)

$(PKG_FINISH)
