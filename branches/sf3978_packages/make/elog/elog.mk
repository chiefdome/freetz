$(call PKG_INIT_BIN, 2.7.8)
$(PKG)_SOURCE:=elog-$($(PKG)_VERSION)-1.tar.gz
$(PKG)_SITE:=https://midas.psi.ch/elog/download/tar
$(PKG)_BINARY:=$($(PKG)_DIR)/elogd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/elogd
$(PKG)_ELOG:=$($(PKG)_DIR)/elog
$(PKG)_TARGET_ELOG:=$($(PKG)_DEST_DIR)/usr/bin/elog
$(PKG)_ELCONV:=$($(PKG)_DIR)/elconv
$(PKG)_TARGET_ELCONV:=$($(PKG)_DEST_DIR)/usr/bin/elconv
$(PKG)_SOURCE_MD5:=a493dc9a4dcd5cceea45403cc4d24b03

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(ELOG_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
$($(PKG)_TARGET_ELOG): $($(PKG)_ELOG)
	$(INSTALL_BINARY_STRIP)
$($(PKG)_TARGET_ELCONV): $($(PKG)_ELCONV)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) \
		    $($(PKG)_TARGET_ELOG) \
		    $($(PKG)_TARGET_ELCONV)

$(pkg)-clean:
	-$(MAKE) -C $(ELOG_DIR) clean
	 $(RM) $(ELOG_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(ELOG_TARGET_BINARY) \
	      $(ELOG_TARGET_ELOG) \
	      $(ELOG_TARGET_ELCONV)

$(PKG_FINISH)
