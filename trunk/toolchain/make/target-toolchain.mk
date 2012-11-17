TARGET_TOOLCHAIN_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
TARGET_TOOLCHAIN_DEVEL_SYSROOT=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/

TARGET_TOOLCHAIN_PREFIX-gcc-final-phase=$(TARGET_TOOLCHAIN_STAGING_DIR)
# NB: in order the toolchain to be relocatable this must be a subdir of TARGET_TOOLCHAIN_PREFIX-gcc-final-phase
# TODO: modify gcc, so that we don't need this hack
TARGET_TOOLCHAIN_SYSROOT=$(TARGET_TOOLCHAIN_PREFIX-gcc-final-phase)/usr/

include $(TOOLCHAIN_DIR)/make/target/binutils/binutils.mk
include $(TOOLCHAIN_DIR)/make/target/gcc/gcc.mk
include $(TOOLCHAIN_DIR)/make/target/uclibc/uclibc.mk
include $(TOOLCHAIN_DIR)/make/target/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/libtool-host/libtool-host.mk
include $(TOOLCHAIN_DIR)/make/target/python-host/python-host.mk
include $(TOOLCHAIN_DIR)/make/target/python-setuptools/python-setuptools.mk
include $(TOOLCHAIN_DIR)/make/target/python-distutilscross/python-distutilscross.mk

TARGET_TOOLCHAIN := binutils gcc $(STDCXXLIB) $(if $(FREETZ_TOOLCHAIN_CCACHE),ccache)
TARGET_TOOLCHAIN += $(if $(FREETZ_TARGET_TOOLCHAIN),binutils_target gcc_target uclibc_target)
TARGET_TOOLCHAIN += libtool-host $(if $(FREETZ_PACKAGE_GDB_HOST),gdbhost)
TARGET_TOOLCHAIN += python-host python-setuptools python-distutilscross

$(TARGET_TOOLCHAIN_DIR):
	@mkdir -p $@

$(TARGET_TOOLCHAIN_STAGING_DIR):
	@mkdir -p $@ $@/bin $@/lib
	@ln -snf . $@/usr
	@mkdir -p $@/usr/$(REAL_GNU_TARGET_NAME)
	@ln -snf ../lib $@/usr/$(REAL_GNU_TARGET_NAME)/lib
	@ln -snf ../include $@/usr/$(REAL_GNU_TARGET_NAME)/include
	@mkdir -p $@/usr/lib/pkgconfig
	@mkdir -p $@/target-utils

target-toolchain: $(TARGET_TOOLCHAIN_DIR) $(TARGET_TOOLCHAIN_STAGING_DIR) \
	$(TARGET_TOOLCHAIN_SYMLINK_DOT_FILE) \
	$(TARGET_CXX_CROSS_COMPILER_SYMLINK_TIMESTAMP) \
	kernel-configured uclibc-configured target-toolchain-kernel-headers \
	$(TARGET_TOOLCHAIN)

target-toolchain-unpacked: $(TARGET_TOOLCHAIN_DIR) \
	uclibc-unpacked \
	binutils-unpacked \
	gcc-unpacked \
	ccache-unpacked

target-toolchain-clean: \
	binutils-uninstall binutils_target-uninstall gcc-uninstall gcc_target-uninstall \
	binutils-clean binutils_target-clean gcc_initial-clean gcc-clean gcc_target-clean uclibc-clean ccache-clean

target-toolchain-dirclean: binutils-dirclean binutils_target-dirclean gcc_initial-dirclean gcc-dirclean gcc_target-dirclean ccache-dirclean uclibc-dirclean
	$(RM) -r $(TARGET_TOOLCHAIN_DIR)

.PHONY: target-toolchain target-toolchain-unpacked target-toolchain-clean target-toolchain-dirclean
