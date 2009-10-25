$(call PKG_INIT_BIN, 1.6.6)
$(PKG)_MAJOR_VERSION:=1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=e5109da756d74c7d98f683f004a539af
$(PKG)_SITE:=http://subversion.tigris.org/downloads/

ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
$(PKG)_LIB_SUFFIX:=a
$(PKG)_BINARY_BUILD_SUBDIR:=
else
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_LIB_SUFFIX:=so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY_BUILD_SUBDIR:=.libs
endif

# Libraries
# Makefile-TODO: create macros for the following definitions
$(PKG)_CLIENT_MAJOR_LIBNAME:=libsvn_client-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_CLIENT_LIBNAME:=$(SUBVERSION_CLIENT_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_CLIENT_LIB:=$($(PKG)_DIR)/subversion/libsvn_client/.libs/$(SUBVERSION_CLIENT_LIBNAME)
$(PKG)_CLIENT_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_CLIENT_LIBNAME)
$(PKG)_CLIENT_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_CLIENT_LIBNAME)

$(PKG)_DELTA_MAJOR_LIBNAME:=libsvn_delta-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_DELTA_LIBNAME:=$(SUBVERSION_DELTA_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_DELTA_LIB:=$($(PKG)_DIR)/subversion/libsvn_delta/.libs/$(SUBVERSION_DELTA_LIBNAME)
$(PKG)_DELTA_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_DELTA_LIBNAME)
$(PKG)_DELTA_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_DELTA_LIBNAME)

$(PKG)_DIFF_MAJOR_LIBNAME:=libsvn_diff-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_DIFF_LIBNAME:=$(SUBVERSION_DIFF_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_DIFF_LIB:=$($(PKG)_DIR)/subversion/libsvn_diff/.libs/$(SUBVERSION_DIFF_LIBNAME)
$(PKG)_DIFF_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_DIFF_LIBNAME)
$(PKG)_DIFF_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_DIFF_LIBNAME)

$(PKG)_FS_MAJOR_LIBNAME:=libsvn_fs-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_FS_LIBNAME:=$(SUBVERSION_FS_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_FS_LIB:=$($(PKG)_DIR)/subversion/libsvn_fs/.libs/$(SUBVERSION_FS_LIBNAME)
$(PKG)_FS_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_FS_LIBNAME)
$(PKG)_FS_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_FS_LIBNAME)

$(PKG)_FS_FS_MAJOR_LIBNAME:=libsvn_fs_fs-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_FS_FS_LIBNAME:=$(SUBVERSION_FS_FS_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_FS_FS_LIB:=$($(PKG)_DIR)/subversion/libsvn_fs_fs/.libs/$(SUBVERSION_FS_FS_LIBNAME)
$(PKG)_FS_FS_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_FS_FS_LIBNAME)
$(PKG)_FS_FS_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_FS_FS_LIBNAME)

$(PKG)_FS_UTIL_MAJOR_LIBNAME:=libsvn_fs_util-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_FS_UTIL_LIBNAME:=$(SUBVERSION_FS_UTIL_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_FS_UTIL_LIB:=$($(PKG)_DIR)/subversion/libsvn_fs_util/.libs/$(SUBVERSION_FS_UTIL_LIBNAME)
$(PKG)_FS_UTIL_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_FS_UTIL_LIBNAME)
$(PKG)_FS_UTIL_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_FS_UTIL_LIBNAME)

$(PKG)_RA_MAJOR_LIBNAME:=libsvn_ra-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_RA_LIBNAME:=$(SUBVERSION_RA_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_RA_LIB:=$($(PKG)_DIR)/subversion/libsvn_ra/.libs/$(SUBVERSION_RA_LIBNAME)
$(PKG)_RA_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_LIBNAME)
$(PKG)_RA_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_RA_LIBNAME)

$(PKG)_RA_LOCAL_MAJOR_LIBNAME:=libsvn_ra_local-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_RA_LOCAL_LIBNAME:=$(SUBVERSION_RA_LOCAL_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_RA_LOCAL_LIB:=$($(PKG)_DIR)/subversion/libsvn_ra_local/.libs/$(SUBVERSION_RA_LOCAL_LIBNAME)
$(PKG)_RA_LOCAL_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_LOCAL_LIBNAME)
$(PKG)_RA_LOCAL_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_RA_LOCAL_LIBNAME)

$(PKG)_RA_NEON_MAJOR_LIBNAME:=libsvn_ra_neon-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_RA_NEON_LIBNAME:=$(SUBVERSION_RA_NEON_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_RA_NEON_LIB:=$($(PKG)_DIR)/subversion/libsvn_ra_neon/.libs/$(SUBVERSION_RA_NEON_LIBNAME)
$(PKG)_RA_NEON_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_NEON_LIBNAME)
$(PKG)_RA_NEON_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_RA_NEON_LIBNAME)

$(PKG)_RA_SVN_MAJOR_LIBNAME:=libsvn_ra_svn-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_RA_SVN_LIBNAME:=$(SUBVERSION_RA_SVN_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_RA_SVN_LIB:=$($(PKG)_DIR)/subversion/libsvn_ra_svn/.libs/$(SUBVERSION_RA_SVN_LIBNAME)
$(PKG)_RA_SVN_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_SVN_LIBNAME)
$(PKG)_RA_SVN_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_RA_SVN_LIBNAME)

$(PKG)_REPOS_MAJOR_LIBNAME:=libsvn_repos-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_REPOS_LIBNAME:=$(SUBVERSION_REPOS_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_REPOS_LIB:=$($(PKG)_DIR)/subversion/libsvn_repos/.libs/$(SUBVERSION_REPOS_LIBNAME)
$(PKG)_REPOS_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_REPOS_LIBNAME)
$(PKG)_REPOS_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_REPOS_LIBNAME)

$(PKG)_SUBR_MAJOR_LIBNAME:=libsvn_subr-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_SUBR_LIBNAME:=$(SUBVERSION_SUBR_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_SUBR_LIB:=$($(PKG)_DIR)/subversion/libsvn_subr/.libs/$(SUBVERSION_SUBR_LIBNAME)
$(PKG)_SUBR_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_SUBR_LIBNAME)
$(PKG)_SUBR_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_SUBR_LIBNAME)

$(PKG)_WC_MAJOR_LIBNAME:=libsvn_wc-$(SUBVERSION_MAJOR_VERSION)
$(PKG)_WC_LIBNAME:=$(SUBVERSION_WC_MAJOR_LIBNAME).$(SUBVERSION_LIB_SUFFIX)
$(PKG)_WC_LIB:=$($(PKG)_DIR)/subversion/libsvn_wc/.libs/$(SUBVERSION_WC_LIBNAME)
$(PKG)_WC_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_WC_LIBNAME)
$(PKG)_WC_TARGET_LIB:=$($(PKG)_DEST_DIR)/usr/lib/$(SUBVERSION_WC_LIBNAME)

# Executables
$(PKG)_SVN_BINARY_NAME:=svn
$(PKG)_SVN_BINARY:=$($(PKG)_DIR)/subversion/$(SUBVERSION_SVN_BINARY_NAME)/$(SUBVERSION_BINARY_BUILD_SUBDIR)/$(SUBVERSION_SVN_BINARY_NAME)
$(PKG)_SVN_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(SUBVERSION_SVN_BINARY_NAME)

$(PKG)_SVNADMIN_BINARY_NAME:=svnadmin
$(PKG)_SVNADMIN_BINARY:=$($(PKG)_DIR)/subversion/$(SUBVERSION_SVNADMIN_BINARY_NAME)/$(SUBVERSION_BINARY_BUILD_SUBDIR)/$(SUBVERSION_SVNADMIN_BINARY_NAME)
$(PKG)_SVNADMIN_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(SUBVERSION_SVNADMIN_BINARY_NAME)

$(PKG)_SVNDUMPFILTER_BINARY_NAME:=svndumpfilter
$(PKG)_SVNDUMPFILTER_BINARY:=$($(PKG)_DIR)/subversion/$(SUBVERSION_SVNDUMPFILTER_BINARY_NAME)/$(SUBVERSION_BINARY_BUILD_SUBDIR)/$(SUBVERSION_SVNDUMPFILTER_BINARY_NAME)
$(PKG)_SVNDUMPFILTER_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(SUBVERSION_SVNDUMPFILTER_BINARY_NAME)

$(PKG)_SVNLOOK_BINARY_NAME:=svnlook
$(PKG)_SVNLOOK_BINARY:=$($(PKG)_DIR)/subversion/$(SUBVERSION_SVNLOOK_BINARY_NAME)/$(SUBVERSION_BINARY_BUILD_SUBDIR)/$(SUBVERSION_SVNLOOK_BINARY_NAME)
$(PKG)_SVNLOOK_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(SUBVERSION_SVNLOOK_BINARY_NAME)

$(PKG)_SVNSERVE_BINARY_NAME:=svnserve
$(PKG)_SVNSERVE_BINARY:=$($(PKG)_DIR)/subversion/$(SUBVERSION_SVNSERVE_BINARY_NAME)/$(SUBVERSION_BINARY_BUILD_SUBDIR)/$(SUBVERSION_SVNSERVE_BINARY_NAME)
$(PKG)_SVNSERVE_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(SUBVERSION_SVNSERVE_BINARY_NAME)

$(PKG)_SVNSYNC_BINARY_NAME:=svnsync
$(PKG)_SVNSYNC_BINARY:=$($(PKG)_DIR)/subversion/$(SUBVERSION_SVNSYNC_BINARY_NAME)/$(SUBVERSION_BINARY_BUILD_SUBDIR)/$(SUBVERSION_SVNSYNC_BINARY_NAME)
$(PKG)_SVNSYNC_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(SUBVERSION_SVNSYNC_BINARY_NAME)

$(PKG)_SVNVERSION_BINARY_NAME:=svnversion
$(PKG)_SVNVERSION_BINARY:=$($(PKG)_DIR)/subversion/$(SUBVERSION_SVNVERSION_BINARY_NAME)/$(SUBVERSION_BINARY_BUILD_SUBDIR)/$(SUBVERSION_SVNVERSION_BINARY_NAME)
$(PKG)_SVNVERSION_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(SUBVERSION_SVNVERSION_BINARY_NAME)


$(PKG)_DEPENDS_ON := apr
$(PKG)_DEPENDS_ON += apr-util
$(PKG)_DEPENDS_ON += neon
$(PKG)_DEPENDS_ON += sqlite
$(PKG)_DEPENDS_ON += zlib

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_SVN
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_SVNADMIN
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_SVNDUMPFILTER
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_SVNLOOK
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_SVNSERVE
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_SVNSYNC
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_SVNVERSION
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_SUBVERSION_STATIC

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# Rename ac_cv_path_(PERL|PYTHON|RUBY) variables to ensure that only subversion
# uses the values we set (the values are cached in config.cache).
# Not doing so might break the compilation of other packages that do require perl/python/ruby at build-time.
# Setting them to "none" is the simplest way to prevent subversion from building perl/python/ruby-bindings.
$(PKG)_CONFIGURE_PRE_CMDS += sed -i -r -e 's/ac(_cv_path_(PERL|PYTHON|RUBY))/subversion\1/g' ./configure ;
$(PKG)_CONFIGURE_ENV += subversion_cv_path_PERL="none"
$(PKG)_CONFIGURE_ENV += subversion_cv_path_PYTHON="none"
$(PKG)_CONFIGURE_ENV += subversion_cv_path_RUBY="none"

$(PKG)_CONFIGURE_OPTIONS += --with-apr="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-apr-util="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-neon="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --disable-neon-version-check
$(PKG)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-all-static
else
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
endif
$(PKG)_CONFIGURE_OPTIONS += --disable-nls

$(PKG)_CONFIGURE_OPTIONS += --disable-mod-activation
$(PKG)_CONFIGURE_OPTIONS += --disable-javahl
$(PKG)_CONFIGURE_OPTIONS += --disable-keychain # MacOS keychain
$(PKG)_CONFIGURE_OPTIONS += --with-apxs=no
$(PKG)_CONFIGURE_OPTIONS += --with-berkeley-db=no
$(PKG)_CONFIGURE_OPTIONS += --with-ctypesgen=no
$(PKG)_CONFIGURE_OPTIONS += --with-gnome-keyring=no
$(PKG)_CONFIGURE_OPTIONS += --with-jdk=no
$(PKG)_CONFIGURE_OPTIONS += --with-kwallet=no
$(PKG)_CONFIGURE_OPTIONS += --with-sasl=no
$(PKG)_CONFIGURE_OPTIONS += --with-swig=no


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_CLIENT_LIB) \
$($(PKG)_DELTA_LIB) \
$($(PKG)_DIFF_LIB) \
$($(PKG)_FS_LIB) \
$($(PKG)_FS_FS_LIB) \
$($(PKG)_FS_UTIL_LIB) \
$($(PKG)_RA_LIB) \
$($(PKG)_RA_LOCAL_LIB) \
$($(PKG)_RA_NEON_LIB) \
$($(PKG)_RA_SVN_LIB) \
$($(PKG)_REPOS_LIB) \
$($(PKG)_SUBR_LIB) \
$($(PKG)_WC_LIB) \
$($(PKG)_SVN_BINARY) \
$($(PKG)_SVNADMIN_BINARY) \
$($(PKG)_SVNDUMPFILTER_BINARY) \
$($(PKG)_SVNLOOK_BINARY) \
$($(PKG)_SVNSERVE_BINARY) \
$($(PKG)_SVNSYNC_BINARY) \
$($(PKG)_SVNVERSION_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SUBVERSION_DIR)

$($(PKG)_CLIENT_STAGING_LIB) \
$($(PKG)_DELTA_STAGING_LIB) \
$($(PKG)_DIFF_STAGING_LIB) \
$($(PKG)_FS_STAGING_LIB) \
$($(PKG)_FS_FS_STAGING_LIB) \
$($(PKG)_FS_UTIL_STAGING_LIB) \
$($(PKG)_RA_STAGING_LIB) \
$($(PKG)_RA_LOCAL_STAGING_LIB) \
$($(PKG)_RA_NEON_STAGING_LIB) \
$($(PKG)_RA_SVN_STAGING_LIB) \
$($(PKG)_REPOS_STAGING_LIB) \
$($(PKG)_SUBR_STAGING_LIB) \
$($(PKG)_WC_STAGING_LIB): \
		$($(PKG)_CLIENT_LIB) \
		$($(PKG)_DELTA_LIB) \
		$($(PKG)_DIFF_LIB) \
		$($(PKG)_FS_LIB) \
		$($(PKG)_FS_FS_LIB) \
		$($(PKG)_FS_UTIL_LIB) \
		$($(PKG)_RA_LIB) \
		$($(PKG)_RA_LOCAL_LIB) \
		$($(PKG)_RA_NEON_LIB) \
		$($(PKG)_RA_SVN_LIB) \
		$($(PKG)_REPOS_LIB) \
		$($(PKG)_SUBR_LIB) \
		$($(PKG)_WC_LIB)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(SUBVERSION_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_CLIENT_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_DELTA_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_DIFF_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_FS_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_FS_FS_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_FS_UTIL_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_NEON_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_SVN_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_REPOS_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_SUBR_MAJOR_LIBNAME).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_WC_MAJOR_LIBNAME).la


#Makefile-TODO: Create parameterized macro INSTALL_LIBRARY_STRIP (something similar to INSTALL_BINARY_STRIP)

$($(PKG)_CLIENT_TARGET_LIB): $($(PKG)_CLIENT_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_CLIENT_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_DELTA_TARGET_LIB): $($(PKG)_DELTA_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_DELTA_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_DIFF_TARGET_LIB): $($(PKG)_DIFF_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_DIFF_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_FS_TARGET_LIB): $($(PKG)_FS_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_FS_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_FS_FS_TARGET_LIB): $($(PKG)_FS_FS_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_FS_FS_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_FS_UTIL_TARGET_LIB): $($(PKG)_FS_UTIL_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_FS_UTIL_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_RA_TARGET_LIB): $($(PKG)_RA_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_RA_LOCAL_TARGET_LIB): $($(PKG)_RA_LOCAL_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_LOCAL_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_RA_NEON_TARGET_LIB): $($(PKG)_RA_NEON_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_NEON_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_RA_SVN_TARGET_LIB): $($(PKG)_RA_SVN_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_RA_SVN_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_REPOS_TARGET_LIB): $($(PKG)_REPOS_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_REPOS_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_SUBR_TARGET_LIB): $($(PKG)_SUBR_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_SUBR_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif

$($(PKG)_WC_TARGET_LIB): $($(PKG)_WC_STAGING_LIB)
ifneq ($(strip $(FREETZ_PACKAGE_SUBVERSION_STATIC)),y)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(SUBVERSION_WC_MAJOR_LIBNAME).so* $(dir $@)
	$(TARGET_STRIP) $@
endif


$($(PKG)_SVN_TARGET_BINARY): $($(PKG)_SVN_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_SVN)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_SVNADMIN_TARGET_BINARY): $($(PKG)_SVNADMIN_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_SVNADMIN)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_SVNDUMPFILTER_TARGET_BINARY): $($(PKG)_SVNDUMPFILTER_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_SVNDUMPFILTER)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_SVNLOOK_TARGET_BINARY): $($(PKG)_SVNLOOK_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_SVNLOOK)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_SVNSERVE_TARGET_BINARY): $($(PKG)_SVNSERVE_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_SVNSERVE)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_SVNSYNC_TARGET_BINARY): $($(PKG)_SVNSYNC_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_SVNSYNC)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_SVNVERSION_TARGET_BINARY): $($(PKG)_SVNVERSION_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_SUBVERSION_SVNVERSION)),y)
	$(INSTALL_BINARY_STRIP)
endif

$(pkg):

$(pkg)-precompiled: \
	$($(PKG)_CLIENT_TARGET_LIB) \
	$($(PKG)_DELTA_TARGET_LIB) \
	$($(PKG)_DIFF_TARGET_LIB) \
	$($(PKG)_FS_TARGET_LIB) \
	$($(PKG)_FS_FS_TARGET_LIB) \
	$($(PKG)_FS_UTIL_TARGET_LIB) \
	$($(PKG)_RA_TARGET_LIB) \
	$($(PKG)_RA_LOCAL_TARGET_LIB) \
	$($(PKG)_RA_NEON_TARGET_LIB) \
	$($(PKG)_RA_SVN_TARGET_LIB) \
	$($(PKG)_REPOS_TARGET_LIB) \
	$($(PKG)_SUBR_TARGET_LIB) \
	$($(PKG)_WC_TARGET_LIB) \
	\
	$($(PKG)_SVN_TARGET_BINARY) \
	$($(PKG)_SVNADMIN_TARGET_BINARY) \
	$($(PKG)_SVNDUMPFILTER_TARGET_BINARY) \
	$($(PKG)_SVNLOOK_TARGET_BINARY) \
	$($(PKG)_SVNSERVE_TARGET_BINARY) \
	$($(PKG)_SVNSYNC_TARGET_BINARY) \
	$($(PKG)_SVNVERSION_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/svn*
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsvn*-$(SUBVERSION_MAJOR_VERSION)*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/subversion-$(SUBVERSION_MAJOR_VERSION)

$(pkg)-uninstall:
	$(RM) \
		$(SUBVERSION_SVN_TARGET_BINARY) \
		$(SUBVERSION_SVNADMIN_TARGET_BINARY) \
		$(SUBVERSION_SVNDUMPFILTER_TARGET_BINARY) \
		$(SUBVERSION_SVNLOOK_TARGET_BINARY) \
		$(SUBVERSION_SVNSERVE_TARGET_BINARY) \
		$(SUBVERSION_SVNSYNC_TARGET_BINARY) \
		$(SUBVERSION_SVNVERSION_TARGET_BINARY) \
		$(SUBVERSION_DEST_DIR)/usr/lib/libsvn*

$(PKG_FINISH)
