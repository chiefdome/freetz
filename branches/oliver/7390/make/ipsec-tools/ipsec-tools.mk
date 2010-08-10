$(call PKG_INIT_BIN, 0.7.2)
$(PKG)_SOURCE:=ipsec-tools-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/ipsec-tools
$(PKG)_SOURCE_MD5:=8a1f3648db1bb06ee7f3d0419508c2fd

ifneq ($(strip $(FREETZ_PACKAGE_IPSEC_TOOLS_STATIC)),y)
$(PKG)_BINARIES_PATH_SUFFIX:=/.libs
endif

$(PKG)_BINARIES:=racoon setkey
$(PKG)_BINARIES_PATH:=racoon$($(PKG)_BINARIES_PATH_SUFFIX) setkey$($(PKG)_BINARIES_PATH_SUFFIX)
ifeq ($(strip $(FREETZ_PACKAGE_IPSEC_TOOLS_WITH_RACOONCTL)),y)
$(PKG)_BINARIES += racoonctl
$(PKG)_BINARIES_PATH += racoon$($(PKG)_BINARIES_PATH_SUFFIX)
endif
ifeq ($(strip $(FREETZ_PACKAGE_IPSEC_TOOLS_WITH_PLAINRSAGEN)),y)
$(PKG)_BINARIES += plainrsa-gen
$(PKG)_BINARIES_PATH += racoon
endif

$(PKG)_BINARIES_BUILD_DIR:=$(join $($(PKG)_BINARIES_PATH:%=$($(PKG)_DIR)/src/%/),$($(PKG)_BINARIES:%=%))
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

ifeq ($(strip $(FREETZ_PACKAGE_IPSEC_TOOLS_STATIC)),y)
IPSEC_TOOLS_STATIC:= -all-static -ldl
LDFLAGS+= -ldl -all-static
$(PKG)_LIBS:=
else
IPSEC_TOOLS_STATIC:=
$(PKG)_LIBS:=libipsec.so libracoon.so
$(PKG)_LIBS_PATH:=libipsec/.libs racoon/.libs
endif
$(PKG)_LIBS_BUILD_DIR:=$(join $($(PKG)_LIBS_PATH:%=$($(PKG)_DIR)/src/%/),$($(PKG)_LIBS:%=%))
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_DEPENDS_ON := openssl

ifeq ($(strip $(FREETZ_PACKAGE_IPSEC_TOOLS_WITH_LZO)),y)
$(PKG)_DEPENDS_ON += lzo
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPSEC_TOOLS_WITH_LZO
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPSEC_TOOLS_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPSEC_TOOLS_WITH_MGMNT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPSEC_TOOLS_WITH_RACOONCTL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPSEC_TOOLS_WITH_PLAINRSAGEN

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc/racoon
$(PKG)_CONFIGURE_OPTIONS += --localstatedir=/var/run
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_IPSEC_TOOLS_WITH_LZO),,--disable-lzo)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_IPSEC_TOOLS_WITH_MGMNT),--enable-management,--disable-management)
$(PKG)_CONFIGURE_OPTIONS += --enable-security-context=no
$(PKG)_CONFIGURE_OPTIONS += --with-kernel-headers=$(FREETZ_BASE_DIR)/$(KERNEL_HEADERS_DIR)
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-natt
$(PKG)_CONFIGURE_OPTIONS += --enable-hybrid
$(PKG)_CONFIGURE_OPTIONS += --enable-security-context=no 
$(PKG)_CONFIGURE_OPTIONS += --enable-adminport
$(PKG)_CONFIGURE_OPTIONS += --without-libradius
$(PKG)_CONFIGURE_OPTIONS += --without-libpam
$(PKG)_CONFIGURE_OPTIONS += --without-readline

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(IPSEC_TOOLS_DIR)  IPSEC_TOOLS_STATIC="$(IPSEC_TOOLS_STATIC)" all

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))

$(foreach library,$($(PKG)_LIBS_BUILD_DIR),$(eval $(call INSTALL_LIBRARY_STRIP_RULE,$(library),$(FREETZ_LIBRARY_PATH))))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(IPSEC_TOOLS_DIR) clean
	$(RM) $(IPSEC_TOOLS_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(IPSEC_TOOLS_BINARIES_TARGET_DIR) $(IPSEC_TOOLS_LIBS_TARGET_DIR)

$(PKG_FINISH)
