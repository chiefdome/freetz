$(call PKG_INIT_BIN, 1.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=65850d0470078269b33eee58cba77ac2
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON := libpcap

$(PKG)_LIBS := -lpthread -lpcap

$(PKG)_CONFIGURE_OPTIONS += --enable-messages \
			    --with-membulk=index8 \
			    --with-hash=xor8 \
			    --with-pcap="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
			    --with-libpcap="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(FPROBE_DIR) \
		LIBS="$(FPROBE_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(FPROBE_DIR) clean
	$(RM) $(FPROBE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(FPROBE_BINARIES_TARGET_DIR)

$(PKG_FINISH)
