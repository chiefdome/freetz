$(call PKG_INIT_BIN, 1.26, sg3_utils, SG3UTILS)
$(PKG)_SOURCE:=sg3_utils-$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://sg.danny.cz/sg/p
$(PKG)_BINARY:=$($(PKG)_DIR)/src/sg_start
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sg_start

$(PKG)_CONFIGURE_OPTIONS += --disable-shared

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SG3UTILS_DIR)/lib
	PATH="$(TARGET_PATH)" \
		$(MAKE) sg_start -C $(SG3UTILS_DIR)/src
	touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SG3UTILS_DIR) clean
	rm -f $(SG3UTILS_DIR)/.installed
	rm -f $(SG3UTILS_DIR)/.built
	rm -f $(SG3UTILS_DIR)/.configured

$(pkg)-uninstall:
	rm -f $(SG3UTILS_TARGET_BINARY)

$(PKG_FINISH)

