# based on buildroot SVN
$(call PKG_INIT_BIN, 4.81)
$(PKG)_SOURCE:=lsof_$($(PKG)_VERSION)_src.tar.bz2
$(PKG)_SITE:=ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/lsof_$($(PKG)_VERSION)_src
$(PKG)_BINARY:=$($(PKG)_DIR)/lsof
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lsof
$(PKG)_SOURCE_MD5:=f7112535c2588d08c9234f157f079676

ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y) 
$(PKG)_HASIPV6 := Y
endif

$(PKG)_CONFIGURE_PRE_CMDS += ln -s Configure configure;

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += DEBUG="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += LSOF_CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += LSOF_CCV="$(FREETZ_TARGET_GCC_VERSION)"
$(PKG)_CONFIGURE_ENV += LINUX_HASIPV6="$(LSOF_HASIPV6)"
$(PKG)_CONFIGURE_ENV += LINUX_HASSELINUX="N"
$(PKG)_CONFIGURE_ENV += LINUX_CLIB="-DGLIBCV=2"
$(PKG)_CONFIGURE_ENV += LSOF_INCLUDE="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_ENV += LSOF_VSTR="$(FREETZ_KERNEL_VERSION)"
$(PKG)_CONFIGURE_OPTIONS += -n linux


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LSOF_DIR) \
		DEBUG="$(TARGET_CFLAGS)" \
		LSOF_HOST="none" \
		LSOF_LOGNAME="none" \
		LSOF_SYSINFO="none" \
		LSOF_USER="none"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LSOF_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LSOF_TARGET_BINARY)

$(PKG_FINISH)
