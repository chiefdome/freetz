$(call PKG_INIT_BIN, 3.7.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=125605249958894148ec26d3c88189f5
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := libpcap

$(PKG)_CONFIGURE_ENV += ac_cv_func_getifaddrs=no \
			ac_cv_header_ifaddrs_h=no \
			ac_cv_header_linux_netfilter_ipv4_ip_queue_h=no \
			ac_cv_header_linux_netfilter_ipv4_ipt_ULOG_h=no

$(PKG)_CONFIGURE_OPTIONS += --enable-shared \
			    --disable-static \
			    --with-psrc=pcap \
			    --with-pcap-include="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libpcap/" \
			    --with-pcap-libraries="$(TARGET_TOOLCHAIN_STAGING_DIR)/"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		  $(SUBMAKE1) -C $(IPCAD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IPCAD_DIR) clean
	 $(RM) $(IPCAD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IPCAD_TARGET_BINARY)

$(PKG_FINISH)
