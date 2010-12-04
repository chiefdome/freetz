BINUTILS_VERSION:=$(TARGET_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_SOURCE:=binutils-$(BINUTILS_VERSION).tar.bz2
ifeq ($(TARGET_TOOLCHAIN_BINUTILS_MAJOR_VERSION),2.18)
BINUTILS_SITE:=@GNU/binutils
else
BINUTILS_SITE:=@KERNEL/linux/devel/binutils
endif
BINUTILS_DIR:=$(TARGET_TOOLCHAIN_DIR)/binutils-$(BINUTILS_VERSION)
BINUTILS_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/binutils
BINUTILS_DIR1:=$(BINUTILS_DIR)-build

BINUTILS_MD5_2.18         := 9d22ee4dafa3a194457caf4706f9cf01
BINUTILS_MD5_2.21.51.0.1  := 3e8b6349f38d6e0feba317055f0ced14
BINUTILS_MD5              := $(BINUTILS_MD5_$(BINUTILS_VERSION))

# We do not rely on the host's gmp/mpfr but use a known working one
BINUTILS_HOST_PREREQ=
BINUTILS_TARGET_PREREQ=

ifndef TARGET_TOOLCHAIN_NO_MPFR
BINUTILS_HOST_PREREQ+=$(GMP_HOST_BINARY) $(MPFR_HOST_BINARY)
BINUTILS_TARGET_PREREQ+=$(GMP_TARGET_BINARY) $(MPFR_TARGET_BINARY)

BINUTILS_EXTRA_CONFIG_OPTIONS+=--with-gmp=$(GMP_HOST_DIR)
BINUTILS_EXTRA_CONFIG_OPTIONS+=--with-mpfr=$(MPFR_HOST_DIR)

BINUTILS_TARGET_CONFIG_OPTIONS+=--with-gmp=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
BINUTILS_TARGET_CONFIG_OPTIONS+=--with-mpfr=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr

ifeq ($(TARGET_TOOLCHAIN_GCC_MAJOR_VERSION),4.5)
BINUTILS_HOST_PREREQ+=$(MPC_HOST_BINARY)
BINUTILS_TARGET_PREREQ+=$(MPC_TARGET_BINARY)

BINUTILS_EXTRA_CONFIG_OPTIONS+=--with-mpc=$(MPC_HOST_DIR)
BINUTILS_TARGET_CONFIG_OPTIONS+=--with-mpc=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
endif

endif

BINUTILS_EXTRA_MAKE_OPTIONS :=
ifeq ($(strip $(FREETZ_STATIC_TOOLCHAIN)),y)
BINUTILS_EXTRA_MAKE_OPTIONS += "LDFLAGS=-all-static"
endif

binutils-source: $(DL_DIR)/$(BINUTILS_SOURCE)
ifneq ($(strip $(DL_DIR)/$(BINUTILS_SOURCE)), $(strip $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)))
$(DL_DIR)/$(BINUTILS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(BINUTILS_SOURCE) $(BINUTILS_SITE) $(BINUTILS_MD5)
endif

binutils-unpacked: $(BINUTILS_DIR)/.unpacked
$(BINUTILS_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_SOURCE) | $(TARGET_TOOLCHAIN_DIR)
	$(RM) -r $(BINUTILS_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BINUTILS_SOURCE)
	set -e; \
	for i in $(BINUTILS_MAKE_DIR)/$(BINUTILS_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(BINUTILS_DIR) $$i; \
	done
	# fool zlib test in all configure scripts so it doesn't find zlib and thus no zlib gets linked in
	sed -i -r -e 's,(zlibVersion)([ \t]*[(][)]),\1WeDontWantZlib\2,g' $$(find $(BINUTILS_DIR) -name "configure" -type f)
	touch $@

$(BINUTILS_DIR1)/.configured: $(BINUTILS_DIR)/.unpacked $(BINUTILS_HOST_PREREQ)
	mkdir -p $(BINUTILS_DIR1)
	(cd $(BINUTILS_DIR1); $(RM) config.cache; \
		CC="$(HOSTCC)" \
		$(BINUTILS_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_PREFIX) \
		--with-sysroot=$(TARGET_TOOLCHAIN_SYSROOT) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-multilib \
		--disable-libssp \
		$(DISABLE_NLS) \
		--disable-werror \
		$(BINUTILS_EXTRA_CONFIG_OPTIONS) \
		$(QUIET) \
	);
	touch $@

$(BINUTILS_DIR1)/.compiled: $(BINUTILS_DIR1)/.configured
	$(MAKE) -C $(BINUTILS_DIR1) MAKEINFO=true configure-host
	$(MAKE) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR1) MAKEINFO=true all
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld: $(BINUTILS_DIR1)/.compiled
	$(MAKE1) -C $(BINUTILS_DIR1) MAKEINFO=true install
	$(call STRIP_TOOLCHAIN_BINARIES,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))
	$(call CREATE_TARGET_NAME_SYMLINKS,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(GNU_TARGET_NAME))

binutils-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(GNU_TARGET_NAME))
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/{libiberty*,ldscripts}

binutils-clean: binutils-uninstall
	$(RM) -r $(BINUTILS_DIR1)

binutils-dirclean: binutils-clean binutils_target-dirclean
	$(RM) -r $(BINUTILS_DIR)

binutils: uclibc-configured binutils-dependencies $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld

.PHONY: binutils binutils-dependencies

#############################################################
#
# build binutils for use on the target system
#
#############################################################
BINUTILS_DIR2:=$(BINUTILS_DIR)-target
$(BINUTILS_DIR2)/.configured: $(BINUTILS_DIR)/.unpacked $(BINUTILS_TARGET_PREREQ)
	mkdir -p $(BINUTILS_DIR2)
	(cd $(BINUTILS_DIR2); $(RM) config.cache; \
		CFLAGS_FOR_BUILD="-g -O2 $(HOST_CFLAGS)" \
		$(TARGET_CONFIGURE_ENV) \
		$(BINUTILS_DIR)/configure \
		--prefix=/usr \
		--with-sysroot=/ \
		--exec-prefix=/usr \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-multilib \
		--without-zlib \
		$(DISABLE_NLS) \
		$(BINUTILS_TARGET_CONFIG_OPTIONS) \
		--disable-werror \
	)
	touch $@

$(BINUTILS_DIR2)/.compiled: $(BINUTILS_DIR2)/.configured
	$(MAKE_ENV) $(MAKE) -C $(BINUTILS_DIR2) MAKEINFO=true all
	touch $@

$(TARGET_UTILS_DIR)/usr/bin/ld: $(BINUTILS_DIR2)/.compiled
	$(MAKE_ENV) $(MAKE1) -C $(BINUTILS_DIR2) \
		tooldir=/usr \
		build_tooldir=/usr \
		MAKEINFO=true \
		DESTDIR=$(TARGET_UTILS_DIR) install
	$(call STRIP_TOOLCHAIN_BINARIES,$(TARGET_UTILS_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(TARGET_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_UTILS_DIR))

binutils_target: $(TARGET_UTILS_DIR)/usr/bin/ld

binutils_target-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_UTILS_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))

binutils_target-clean: binutils_target-uninstall
	$(RM) -r $(BINUTILS_DIR2)

binutils_target-dirclean: binutils_target-clean
