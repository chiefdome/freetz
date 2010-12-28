comma:=,
space:=$(empty) $(empty)
AVM_SOURCE:=$(strip $(subst ",, $(subst $(space),\ ,$(FREETZ_DL_KERNEL_SOURCE))))

AVM_UNPACK__INT_.gz:=z
AVM_UNPACK__INT_.bz2:=j

KERNEL_SUBVERSION:=iln6
KERNEL_BOARD_REF:=$(KERNEL_REF)
KERNEL_MAKE_DIR:=$(MAKE_DIR)/linux
KERNEL_BUILD_DIR:=$(KERNEL_DIR)
KERNEL_BUILD_ROOT_DIR:=$(KERNEL_BUILD_DIR)/linux-$(KERNEL_VERSION)

KERNEL_IMAGE:=vmlinux.eva_pad
KERNEL_TARGET_BINARY:=kernel-$(KERNEL_LAYOUT)-$(KERNEL_REF)-$(AVM_VERSION).bin
KERNEL_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/Config.$(KERNEL_LAYOUT)-$(KERNEL_REF).$(AVM_VERSION)

$(DL_FW_DIR)/$(AVM_SOURCE): | $(DL_FW_DIR)
	@$(call _ECHO, downloading...)
	$(DL_TOOL) $(DL_FW_DIR) .config $(FREETZ_DL_KERNEL_SOURCE) $(FREETZ_DL_KERNEL_SITE) $(FREETZ_DL_KERNEL_SOURCE_MD5) $(SILENT)

# Make sure that a perfectly clean build is performed whenever Freetz package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(KERNEL_DIR)/.unpacked: $(DL_FW_DIR)/$(AVM_SOURCE) | gcc-kernel
	$(RM) -r $(KERNEL_DIR)
	mkdir -p $(KERNEL_BUILD_DIR)
	@$(call _ECHO,checking structure... )
	@KERNEL_SOURCE_CONTENT=` \
		tar \
			-t$(AVM_UNPACK__INT_$(suffix $(strip $(FREETZ_DL_KERNEL_SOURCE)))) \
			-f $(DL_FW_DIR)/$(FREETZ_DL_KERNEL_SOURCE)| \
		grep -m 1 -e '^.*\/\(GPL-\(release_\|\)kernel\.tar\.gz\|linux-2\.6\...\..\/\)$$'`; \
	if [ -z "$${KERNEL_SOURCE_CONTENT}" ]; then \
		$(call ERROR,1,KERNEL_SOURCE_CONTENT is empty) \
	else \
		$(call _ECHO, unpacking... ) \
		if [ ! -z $$(echo "$$KERNEL_SOURCE_CONTENT"|grep -e '.*\/GPL-\(release_\|\)kernel\.tar\.gz') ]; then \
			tar	-O $(VERBOSE) \
				-x$(AVM_UNPACK__INT_$(suffix $(strip $(FREETZ_DL_KERNEL_SOURCE)))) \
				-f $(DL_FW_DIR)/$(FREETZ_DL_KERNEL_SOURCE) \
				--wildcards "*/$${KERNEL_SOURCE_CONTENT##*/}" | \
			tar	-C $(KERNEL_BUILD_DIR) $(VERBOSE) \
				-xz \
				--transform="s|^.*\(linux-2\.6\...\..\/\)|\1|g" --show-transformed; \
		else \
			tar	-C $(KERNEL_BUILD_DIR) $(VERBOSE) \
				-x$(AVM_UNPACK__INT_$(suffix $(strip $(FREETZ_DL_KERNEL_SOURCE)))) \
				-f $(DL_FW_DIR)/$(FREETZ_DL_KERNEL_SOURCE) \
				--transform="s|^.*\(linux-2\.6\...\..\/\)|\1|g" --show-transformed \
				"$$KERNEL_SOURCE_CONTENT"; \
		fi \
	fi
	@if [ ! -d $(KERNEL_BUILD_ROOT_DIR) ]; then \
		$(call ERROR,1,KERNEL_BUILD_ROOT_DIR has wrong structure) \
	fi
	@$(call _ECHO, preparing... )
	@set -e; for i in $(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR) $$i; \
	done
	#Version specific patches
	@set -e; shopt -s nullglob; for i in $(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)/$(AVM_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR) $$i; \
	done
	@for i in $(KERNEL_LINKING_FILES); do \
		if [ -e $(KERNEL_BUILD_ROOT_DIR)/$$i -a \
		! -e $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_} ]; then \
			$(call MESSAGE, Linking  $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_}); \
			ln -sf ../../$$i $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_}; \
		fi \
	done
	@for i in avm_net_trace.h avm_net_trace_ioctl.h; do \
		if [ -e $(KERNEL_BUILD_ROOT_DIR)/drivers/char/avm_net_trace/$$i -a \
			! -e $(KERNEL_BUILD_ROOT_DIR)/include/linux/$$i ]; then \
				$(call MESSAGE, Linking  $(KERNEL_BUILD_ROOT_DIR)/include/linux/$$i); \
				ln -sf ../../drivers/char/avm_net_trace/$$i \
					$(KERNEL_BUILD_ROOT_DIR)/include/linux/$$i; \
		fi \
	done
	@for i in $$(find $(KERNEL_BUILD_ROOT_DIR) -name Makefile.26 -printf '%h\n'); do \
		if [ ! -e $$i/Makefile ] ; then \
			$(call MESSAGE, Linking  $$i/Makefile); \
			ln -sf Makefile.26 $$i/Makefile; \
		fi \
	done
	@for i in $$(find $(KERNEL_BUILD_ROOT_DIR) -name Makefile -exec \
		awk '/(obj|subdir)-.*=/{ \
		while (match ($$0,/\\/)) {sub(/\\/," "); getline l;$$0=$$0""l} \
		gsub(/(#.*|.*=)/,""); \
		if (! match ($$0,/,/)) { \
			dirname=substr(FILENAME,1,length(FILENAME)-8); \
			for (i=1;i<=NF;i++) { \
				if (match ($$i,/\.o$$|\$$/)) { \
					$$i=""; \
				} else if (substr($$i,length($$i))!="/") { \
					$$i=$$i"/"; \
				} \
				if ($$i!="") { \
					if (system("test -e "dirname""$$i"Makefile")) { \
						print dirname""$$i"Makefile"; \
					} \
				} \
			} \
		} \
	}' {} '+'|sort -u); do \
		$(call MESSAGE, Creating $$i); \
		mkdir -p $$(dirname "$$i"); \
		[ -h $$i ] && $(RM) $$i; \
		touch $$i; \
	done
	@for i in $$(find $(KERNEL_BUILD_ROOT_DIR) -name Kconfig -exec grep -hs "source.*Kconfig" {} '+'| \
		sed -e 's/\(.*\)#.*/\1/g;s/.*source //g;s/"//g'|sort -u); do \
		if [ ! -e $(KERNEL_BUILD_ROOT_DIR)/$$i ]; then \
			$(call MESSAGE, Creating $(KERNEL_BUILD_ROOT_DIR)/$$i); \
			mkdir -p $(KERNEL_BUILD_ROOT_DIR)/$${i%\/*}; \
			[ -h $(KERNEL_BUILD_ROOT_DIR)/$$i ] && \
				$(RM) $(KERNEL_BUILD_ROOT_DIR)/$$i; \
			touch $(KERNEL_BUILD_ROOT_DIR)/$$i; \
		fi \
	done
	ln -s linux-$(KERNEL_VERSION) $(KERNEL_DIR)/linux
	touch $@

$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	$(call _ECHO, configuring... )
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_ROOT_DIR)/.config
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		oldconfig
	touch $@

$(KERNEL_DIR)/.prepared: $(KERNEL_DIR)/.configured
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		prepare
	touch $@

$(KERNEL_HEADERS_DEVEL_DIR)/include/linux/version.h: $(KERNEL_DIR)/.prepared
ifeq ($(strip $(FREETZ_KERNEL_VERSION_2_6_13_1)),y)
	$(call COPY_KERNEL_HEADERS,$(KERNEL_BUILD_ROOT_DIR),$(KERNEL_HEADERS_DEVEL_DIR),{asm$(comma)asm-generic$(comma)linux$(comma)mtd$(comma)scsi$(comma)video}
else
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_HDR_PATH=$(KERNEL_HEADERS_DEVEL_DIR) \
		headers_install
	find "$(KERNEL_HEADERS_DEVEL_DIR)" \( -name "..install.cmd" -o -name ".install" \) -exec rm -f \{\} \+
endif
	touch $@

target-toolchain-kernel-headers: $(TARGET_TOOLCHAIN_KERNEL_VERSION_HEADER)
$(TARGET_TOOLCHAIN_KERNEL_VERSION_HEADER): $(TOPDIR)/.config $(KERNEL_HEADERS_DEVEL_DIR)/include/linux/version.h | $(if $(FREETZ_BUILD_TOOLCHAIN),$(TARGET_TOOLCHAIN_STAGING_DIR),$(TARGET_CROSS_COMPILER))
	@$(call COPY_KERNEL_HEADERS,$(KERNEL_HEADERS_DEVEL_DIR),$(TARGET_TOOLCHAIN_STAGING_DIR)/usr)
	@touch $@

$(KERNEL_BUILD_ROOT_DIR)/$(KERNEL_IMAGE): $(KERNEL_DIR)/.prepared $(TOOLS_DIR)/lzma $(TOOLS_DIR)/lzma2eva
	$(call _ECHO, kernel image... )
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$(KERNEL_IMAGE)
	touch -c $@

kernel-force:
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$(KERNEL_IMAGE)

$(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY): $(KERNEL_BUILD_ROOT_DIR)/$(KERNEL_IMAGE)
	cp $(KERNEL_BUILD_ROOT_DIR)/$(KERNEL_IMAGE) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	cp $(KERNEL_BUILD_ROOT_DIR)/System.map $(KERNEL_TARGET_DIR)/System-$(KERNEL_LAYOUT)-$(KERNEL_REF)-$(AVM_VERSION).map
	echo "$(KERNEL_SUBVERSION)" > $(KERNEL_TARGET_DIR)/.version-$(KERNEL_LAYOUT)-$(KERNEL_REF)-$(AVM_VERSION)
	touch -c $@

$(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT): $(KERNEL_BUILD_ROOT_DIR)/$(KERNEL_IMAGE)
	@$(call _ECHO, modules... )
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(FREETZ_BASE_DIR)/$(KERNEL_DIR)" \
		modules
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(FREETZ_BASE_DIR)/$(KERNEL_DIR)" \
		modules_install
	touch $@

$(KERNEL_MODULES_DIR)/.modules-$(KERNEL_LAYOUT): $(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT)
	$(RM) -r $(KERNEL_MODULES_DIR)/lib
	mkdir -p $(KERNEL_MODULES_DIR)
	KERNEL_MODULES_SOURCE_DIR=$(KERNEL_DIR)/lib/modules/*/kernel; \
	tar -cf - -C $$KERNEL_MODULES_SOURCE_DIR \
		. | tar -xf - -C $(KERNEL_MODULES_DIR)
	touch $@

kernel-precompiled: pkg-echo-start $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY) $(KERNEL_MODULES_DIR)/.modules-$(KERNEL_LAYOUT) pkg-echo-done

kernel-configured: $(KERNEL_DIR)/.prepared

kernel-modules: $(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT)

kernel-menuconfig: $(KERNEL_DIR)/.configured
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		menuconfig
	-cp -f $(KERNEL_BUILD_ROOT_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-oldconfig: $(KERNEL_DIR)/.configured
	-cp -f $(KERNEL_BUILD_ROOT_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-source: $(KERNEL_DIR)/.unpacked

kernel-clean:
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		clean

kernel-dirclean:
	$(RM) -r $(SOURCE_DIR_ROOT)/kernel
	$(RM) $(KERNEL_TARGET_DIR)/.version-*
	$(RM) $(KERNEL_TARGET_DIR)/System*
	$(RM) $(KERNEL_TARGET_DIR)/kernel-*
	$(RM) -r $(KERNEL_TARGET_DIR)/modules-*

kernel-distclean: kernel-dirclean

pkg-echo-start:
	@$(RM) $(ECHO_ITEM_START) $(ECHO_ITEM_BUILD)

pkg-echo-done:
	@$(call _ECHO_DONE)

.PHONY: kernel-configured kernel-modules kernel-menuconfig kernel-oldconfig target-toolchain-kernel-headers
