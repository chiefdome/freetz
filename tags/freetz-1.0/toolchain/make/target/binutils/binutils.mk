BINUTILS_VERSION:=$(TARGET_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_SOURCE:=binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_STABLE_SITE:=http://ftp.gnu.org/gnu/binutils
BINUTILS_DEVELOPER_SITE:=http://ftp.kernel.org/pub/linux/devel/binutils
BINUTILS_DIR:=$(TARGET_TOOLCHAIN_DIR)/binutils-$(BINUTILS_VERSION)
BINUTILS_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/binutils
BINUTILS_DIR1:=$(BINUTILS_DIR)-build

ifeq ($(strip $(FREETZ_STATIC_TOOLCHAIN)),y)
BINUTILS_EXTRA_MAKE_OPTIONS:="LDFLAGS=-all-static"
else
BINUTILS_EXTRA_MAKE_OPTIONS:=
endif

ifneq ($(strip $(DL_DIR)/$(BINUTILS_SOURCE)), $(strip $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)))
$(DL_DIR)/$(BINUTILS_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(BINUTILS_STABLE_SITE)/$(BINUTILS_SOURCE) || \
	wget -P $(DL_DIR) $(BINUTILS_DEVELOPER_SITE)/$(BINUTILS_SOURCE)
endif

$(BINUTILS_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_SOURCE)
	mkdir -p $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BINUTILS_SOURCE)
	for i in $(BINUTILS_MAKE_DIR)/$(BINUTILS_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(BINUTILS_DIR) $$i; \
	done
	touch $@

$(BINUTILS_DIR1)/.configured: $(BINUTILS_DIR)/.unpacked
	mkdir -p $(BINUTILS_DIR1)
	( cd $(BINUTILS_DIR1); \
		CC="$(HOSTCC)" \
		$(BINUTILS_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--with-build-sysroot="$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/" \
		--with-sysroot="$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/" \
		$(DISABLE_NLS) \
		--disable-werror \
	);
	touch $@

$(BINUTILS_DIR1)/binutils/objdump: $(BINUTILS_DIR1)/.configured
	$(MAKE) -C $(BINUTILS_DIR1) configure-host
	$(MAKE) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR1) all

$(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/bin/ld: $(BINUTILS_DIR1)/binutils/objdump
	$(MAKE) -C $(BINUTILS_DIR1) install

binutils-dependancies:
	@if ! which bison > /dev/null ; then \
		echo -e "\n\nYou must install 'bison' on your build machine\n"; \
		exit 1; \
	fi;
	@if ! which flex > /dev/null ; then \
		echo -e "\n\nYou must install 'flex' on your build machine\n"; \
		exit 1; \
	fi;
	@if ! which msgfmt > /dev/null ; then \
		echo -e "\n\nYou must install 'gettext' on your build machine\n"; \
		exit 1; \
	fi;

binutils-source: $(DL_DIR)/$(BINUTILS_SOURCE)

binutils-clean:
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/*{ar,as,ld,nm,objdump,ranlib,strip} \
	$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/{libiberty*,ldscripts}
	-$(MAKE) -C $(BINUTILS_DIR1) DESTDIR=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		tooldir=/usr build_tooldir=/usr uninstall
	-$(MAKE) -C $(BINUTILS_DIR1) clean
			    

binutils-dirclean:
	rm -rf $(BINUTILS_DIR1)

binutils: uclibc-configured binutils-dependancies $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/bin/ld

.PHONY: binutils binutils-dependancies