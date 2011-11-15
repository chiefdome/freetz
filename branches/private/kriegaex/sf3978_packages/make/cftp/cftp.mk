$(call PKG_INIT_BIN, 0.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=e497c2cf060a6906f48ac99f55bedc8a
$(PKG)_SITE:=http://nih.at/$(pkg)/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := ncurses
$(PKG)_CONFIGURE_OPTIONS += --enable-sftp

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		cp $(CFTP_DIR)/fn_bind.c $(CFTP_DIR)/fn_bind1.c
		cp $(CFTP_DIR)/functions.c $(CFTP_DIR)/functions1.c
		cp $(CFTP_DIR)/keys.c $(CFTP_DIR)/keys1.c
		cp $(CFTP_DIR)/rc.c $(CFTP_DIR)/rc1.c
		$(SUBMAKE1) -C $(CFTP_DIR) \
		CC="$(HOSTCC)" \
		LINK="$(HOSTCC) -o mkbind" \
		CFLAGS="" \
		CPPFLAGS="" \
		LIBS="-lresolv -lnsl -lncurses" \
		mkbind
		$(SUBMAKE1) -C $(CFTP_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(CFTP_DIR) clean
	$(RM) $(CFTP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(CFTP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
