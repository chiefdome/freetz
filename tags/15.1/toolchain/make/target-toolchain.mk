ifneq ($(strip $(DS_BUILD_TOOLCHAIN)),y)
	include $(TOOLCHAIN_DIR)/make/target/gcc/libgcc.mk
	include $(TOOLCHAIN_DIR)/make/target/gdb/gdb.mk
	include $(TOOLCHAIN_DIR)/make/target/uclibc/uclibc.mk
else

include $(TOOLCHAIN_DIR)/make/target/*/*.mk

ifeq ($(strip $(DS_TARGET_CCACHE)),y)
	CCACHE:=ccache
endif

TARGET_TOOLCHAIN:=binutils gcc $(CCACHE) gdb

$(TARGET_TOOLCHAIN_DIR):
	@mkdir -p $@

$(TARGET_TOOLCHAIN_STAGING_DIR):
	@mkdir -p $@
	@mkdir -p $@/bin
	@mkdir -p $@/lib
	@mkdir -p $@/include
	@mkdir -p $@/usr
	@mkdir -p $@/$(REAL_GNU_TARGET_NAME)
	@ln -snf ../include $@/usr/include
	@ln -snf ../lib $@/usr/lib
	@ln -snf ../lib $@/$(REAL_GNU_TARGET_NAME)/lib
	#moved from target-toolchain because link is needed for uclibc-build
	#TODO: prehaps the next 2 Steps schould be done somewhere else?
	@rm -f $(TOOLCHAIN_DIR)/target
	@ln -s $(BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)/$(REAL_GNU_TARGET_NAME) $(TOOLCHAIN_DIR)/target

target-toolchain: $(TARGET_TOOLCHAIN_DIR) $(TARGET_TOOLCHAIN_STAGING_DIR) \
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
	-$(MAKE) -C $(UCLIBC_DIR) clean
	-$(MAKE) -C $(BINUTILS_DIR) clean
	rm -rf $(GCC_BUILD_DIR1)
	rm -rf $(GCC_BUILD_DIR2)
ifeq ($(strip $(DS_TARGET_CCACHE)),y)
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin-ccache/$(REAL_GNU_TARGET_NAME)*
	-$(MAKE) -C $(CCACHE_DIR) clean
endif

target-toolchain-dirclean:
	rm -rf $(TARGET_TOOLCHAIN_DIR)

target-toolchain-distclean: target-toolchain-dirclean
	rm -rf $(TOOLCHAIN_BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)
	rm -f $(TOOLCHAIN_DIR)/target

endif