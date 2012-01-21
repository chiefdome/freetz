$(call PKG_INIT_BIN, 0.8.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=e812ac26323f3a8113ce1a0761ce9544
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON := openssl zlib libpcap
$(PKG)_LDFLAGS := -lpcap -lcrypto -lcrypt -lnsl -lz -lpthread -ldl

$(PKG)_CONFIGURE_OPTIONS += --enable-switch_user
$(PKG)_CONFIGURE_OPTIONS += --disable-perl
$(PKG)_CONFIGURE_OPTIONS += --disable-option-checking

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(OPENDCHUB_DIR) \
		LDFLAGS="$(TARGET_LDFLAGS) $(OPENDCHUB_LDFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(OPENDCHUB_DIR) clean
	$(RM) $(OPENDCHUB_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(OPENDCHUB_BINARIES_TARGET_DIR)

$(PKG_FINISH)
