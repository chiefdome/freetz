$(call PKG_INIT_BIN, 2.2.0)
$(PKG)_SOURCE := $(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5 := acac2b5f2d9f43bfd5ea2a5cf4c71fe5
$(PKG)_SITE := @SF/$(pkg)

$(PKG)_LIBS := uams_guest uams_dhx2_passwd
$(PKG)_LIBS_BUILD_DIR := $($(PKG)_LIBS:%=$($(PKG)_DIR)/etc/uams/.libs/%.so)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%.so)

$(PKG)_BINS_AFPD := afpd hash
$(PKG)_BINS_AFPD_BUILD_DIR := $($(PKG)_BINS_AFPD:%=$($(PKG)_DIR)/etc/afpd/%)
$(PKG)_BINS_AFPD_TARGET_DIR := $($(PKG)_BINS_AFPD:%=$($(PKG)_DEST_DIR)/sbin/%)

$(PKG)_BINS_DBD := cnid_dbd cnid_metad dbd
$(PKG)_BINS_DBD_BUILD_DIR := $($(PKG)_BINS_DBD:%=$($(PKG)_DIR)/etc/cnid_dbd/%)
$(PKG)_BINS_DBD_TARGET_DIR := $($(PKG)_BINS_DBD:%=$($(PKG)_DEST_DIR)/sbin/%)

$(PKG)_DEPENDS_ON := db libgcrypt
ifeq ($(strip $(FREETZ_PACKAGE_NETATALK_ENABLE_ZEROCONF)),y)
$(PKG)_DEPENDS_ON += avahi
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_NETATALK_ENABLE_ZEROCONF

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --disable-a2boot
$(PKG)_CONFIGURE_OPTIONS += --disable-afs
$(PKG)_CONFIGURE_OPTIONS += --disable-cups
$(PKG)_CONFIGURE_OPTIONS += --disable-ddp
$(PKG)_CONFIGURE_OPTIONS += --disable-srvloc
$(PKG)_CONFIGURE_OPTIONS += --disable-timelord
$(PKG)_CONFIGURE_OPTIONS += --disable-admin-group
$(PKG)_CONFIGURE_OPTIONS += --disable-shell-check
$(PKG)_CONFIGURE_OPTIONS += --disable-tcp-wrappers
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NETATALK_ENABLE_ZEROCONF),--enable-zeroconf,--disable-zeroconf)
$(PKG)_CONFIGURE_OPTIONS += --with-cnid-default-backend=dbd
$(PKG)_CONFIGURE_OPTIONS += --with-cnid-dbd-backend
$(PKG)_CONFIGURE_OPTIONS += --with-cnid-tdb-backend
$(PKG)_CONFIGURE_OPTIONS += --without-acls
$(PKG)_CONFIGURE_OPTIONS += --without-cnid-cdb-backend
$(PKG)_CONFIGURE_OPTIONS += --without-cnid-last-backend
$(PKG)_CONFIGURE_OPTIONS += --without-ldap
$(PKG)_CONFIGURE_OPTIONS += --with-uams-path="$(FREETZ_LIBRARY_PATH)"
$(PKG)_CONFIGURE_OPTIONS += --with-bdb="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libgcrypt-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-ssl-dir=no
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir="/mod/etc"
$(PKG)_CONFIGURE_OPTIONS += --disable-debugging

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINS_AFPD_BUILD_DIR) $($(PKG)_BINS_DBD_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NETATALK_DIR)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/etc/uams/.libs/%
	$(INSTALL_LIBRARY_STRIP)
	ln -sf uams_dhx2_passwd.so $(NETATALK_DEST_LIBDIR)/uams_dhx2.so

$($(PKG)_BINS_AFPD_TARGET_DIR): $($(PKG)_DEST_DIR)/sbin/%: $($(PKG)_DIR)/etc/afpd/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_BINS_DBD_TARGET_DIR): $($(PKG)_DEST_DIR)/sbin/%: $($(PKG)_DIR)/etc/cnid_dbd/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINS_AFPD_TARGET_DIR) $($(PKG)_BINS_DBD_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NETATALK_DIR) clean

$(pkg)-uninstall:
	$(RM) $(NETATALK_LIBS_TARGET_DIR) $(NETATALK_BINS_AFPD_TARGET_DIR) $(NETATALK_BINS_DBD_TARGET_DIR)

$(PKG_FINISH)
