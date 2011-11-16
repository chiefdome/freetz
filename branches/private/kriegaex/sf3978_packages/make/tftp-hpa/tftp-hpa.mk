$(call PKG_INIT_BIN, 5.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=86ddd4e33395b0ae43b3ddce78605d8d
$(PKG)_SITE:=http://mirrors.dotsrc.org/software/network/tftp/
$(PKG)_BINARIES:=tftpd
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/tftpd/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_OPTIONS += --without-tcpwrappers
$(PKG)_CONFIGURE_OPTIONS += --without-remap
$(PKG)_CONFIGURE_OPTIONS += --without-readline
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--with-ipv6,--without-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(TFTP_HPA_DIR)

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
