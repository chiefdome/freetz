$(call PKG_INIT_BIN, 5.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=d086b1bd6e5ed6375ad407e273afccdf
$(PKG)_SITE:=http://www.in.kernel.org/pub/software/network/tftp/
$(PKG)_BINARIES:=tftpd
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/tftpd/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --without-tcpwrappers \
			    --without-remap \
			    --without-readline \
			    --without-ipv6 \
			    --disable-largefile

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(TFTP_HPA_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/tftpd/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(TFTP_HPA_DIR) clean
	$(RM) $(CNTLM_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(TFTP_HPA_BINARIES_TARGET_DIR)

$(PKG_FINISH)
