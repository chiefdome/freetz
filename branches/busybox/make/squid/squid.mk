$(call PKG_INIT_BIN, 3.0.STABLE26)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=f48c2b58b05715f40be0d29ab72fed34
$(PKG)_SITE:=http://www.squid-cache.org/Versions/v$(firstword $(subst ., ,$($(PKG)_VERSION)))/$(firstword $(subst ., ,$($(PKG)_VERSION))).$(word 2,$(subst ., ,$($(PKG)_VERSION)))
$(PKG)_BINARY:=$($(PKG)_DIR)/src/squid
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/squid

$(PKG)_DEPENDS_ON := $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SQUID_TRANSPARENT

$(PKG)_CONFIGURE_ENV += ac_cv_func_setresuid="yes"
$(PKG)_CONFIGURE_ENV += ac_cv_func_setresuid="yes"
$(PKG)_CONFIGURE_ENV += ac_cv_func_strnstr="no"
$(PKG)_CONFIGURE_ENV += ac_cv_func_va_copy="yes"
$(PKG)_CONFIGURE_ENV += ac_cv_func___va_copy="yes"

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_SQUID_TRANSPARENT),--enable-linux-netfilter,--disable-linux-netfilter)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SQUID_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SQUID_DIR) clean
	$(RM) $(SQUID_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SQUID_TARGET_BINARY)

$(PKG_FINISH)
