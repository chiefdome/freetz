$(call PKG_INIT_BIN, 0.6.0)
$(PKG)_SOURCE:=$(pkg)-20081016.tar.gz
$(PKG)_SOURCE_MD5:=814456ccc8fea5688382b7ec55fe44eb
$(PKG)_SITE:=http://www.wormulon.net/$(pkg)/
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(SMAP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr \
		-DRAW_SOCKET -DHAVE_RANDOM -DSMAP_OS=linux" \
		LD="$(TARGET_LD)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lm -lpthread" \
		smap

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(SMAP_DIR) clean
	$(RM) $(SMAP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SMAP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
