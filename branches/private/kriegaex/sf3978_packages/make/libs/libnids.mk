$(call PKG_INIT_LIB, 1.24)
$(PKG)_LIB_VERSION:=1.24
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=72d37c79c85615ffe158aa524d649610
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_ENV += ac_cv_lbl_unaligned_fail=no
$(PKG)_DEPENDS_ON := libpcap libnet

$(PKG)_CONFIGURE_OPTIONS += --enable-shared \
			    --enable-static \
			    --host=mipsel-linux \
			    --target=mipsel-linux \
			    --includedir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include \
			    --libdir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib \
			    --mandir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man
			    
$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(LIBNIDS_DIR) \
	  CFLAGS="$(TARGET_CFLAGS) -D_BSD_SOURCE -DLIBNET_VER=1 -DHAVE_ICMPHDR=1 \
	  -DHAVE_TCP_STATES=1 -DHAVE_BSD_UDPHDR=1" \
	  PCAP_CFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include" \
	  PCAPLIB="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib -lpcap" \
	  LNET_CFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include -DLIBNET_LIL_ENDIAN \
	  -D_BSD_SOURCE -D__BSD_SOURCE -D__FAVOR_BSD -DHAVE_NET_ETHERNET_H" \
	  LNETLIB="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib -lnet" \
	  LDFLAGS="$(TARGET_LDFLAGS)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE1) -C $(LIBNIDS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libnids.a

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(LIBNIDS_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libnids* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/*nids.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libnids \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/man/man?/libnids*

$(pkg)-uninstall:
	$(RM) $(LIBNIDS_TARGET_DIR)/libnids*.so*

$(PKG_FINISH)
