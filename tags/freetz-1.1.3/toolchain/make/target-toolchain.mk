include $(TOOLCHAIN_DIR)/make/target/*/*.mk

ifeq ($(strip $(FREETZ_TARGET_CCACHE)),y)
	CCACHE:=ccache
endif

ifeq ($(strip $(FREETZ_TARGET_TOOLCHAIN)),y)
	TARGETT:=binutils_target gcc_target uclibc_target
endif

TARGET_TOOLCHAIN:=binutils gcc $(CCACHE) $(TARGETT) gdb

$(TARGET_TOOLCHAIN_DIR):
	@mkdir -p $@

$(TARGET_TOOLCHAIN_STAGING_DIR):
	@mkdir -p $@
	@mkdir -p $@/bin
	@mkdir -p $@/lib
	@mkdir -p $@/lib/pkgconfig
	@mkdir -p $@/include
	@mkdir -p $@/usr
	@mkdir -p $@/target-utils
	@mkdir -p $@/$(REAL_GNU_TARGET_NAME)
	@ln -snf ../bin $@/usr/bin
	@ln -snf ../include $@/usr/include
	@ln -snf ../lib $@/usr/lib
	@ln -snf ../lib $@/$(REAL_GNU_TARGET_NAME)/lib

target-toolchain: $(TARGET_TOOLCHAIN_DIR) $(TARGET_TOOLCHAIN_STAGING_DIR) $(TARGET_TOOLCHAIN_SYMLINK) \
					kernel-configured uclibc-configured \
					$(TARGET_TOOLCHAIN)
	
target-toolchain-source: $(TARGET_TOOLCHAIN_DIR) \
	$(UCLIBC_DIR)/.unpacked \
	$(BINUTILS_DIR)/.unpacked \
	$(GCC_DIR)/.unpacked \
	$(CCACHE_DIR)/.unpacked

target-toolchain-clean:
	rm -f $(UCLIBC_DIR)/.config
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)*
	rm -rf $(TARGET_UTILS_DIR)/*
	-$(MAKE) -C $(UCLIBC_DIR) clean
	-$(MAKE) -C $(BINUTILS_DIR) clean
	rm -rf $(GCC_BUILD_DIR1)
	rm -rf $(GCC_BUILD_DIR2)
	rm -rf $(GCC_BUILD_DIR3)
ifeq ($(strip $(FREETZ_TARGET_CCACHE)),y)
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin-ccache/$(REAL_GNU_TARGET_NAME)*
	-$(MAKE) -C $(CCACHE_DIR) clean
endif

target-toolchain-dirclean:
	rm -rf $(TARGET_TOOLCHAIN_DIR)
	rm -rf $(TOOLCHAIN_BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)
	rm -f $(TOOLCHAIN_DIR)/target

target-toolchain-distclean: target-toolchain-dirclean

