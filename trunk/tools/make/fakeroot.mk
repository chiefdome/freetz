FAKEROOT_VERSION:=1.18.4
FAKEROOT_SOURCE:=fakeroot_$(FAKEROOT_VERSION).orig.tar.bz2
FAKEROOT_SOURCE_MD5:=706171d8d520b1ca1576ac73f2ceb4f3
FAKEROOT_SITE:=http://ftp.debian.org/debian/pool/main/f/fakeroot

FAKEROOT_MAKE_DIR:=$(TOOLS_DIR)/make
FAKEROOT_DIR:=$(TOOLS_SOURCE_DIR)/fakeroot-$(FAKEROOT_VERSION)
FAKEROOT_MAINARCH_DIR:=$(FAKEROOT_DIR)/build/arch
FAKEROOT_BIARCH_DIR:=$(FAKEROOT_DIR)/build/biarch

FAKEROOT_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build
FAKEROOT_MAINARCH_LD_PRELOAD_PATH:=$(FAKEROOT_DESTDIR)/lib
FAKEROOT_BIARCH_LD_PRELOAD_PATH:=$(FAKEROOT_DESTDIR)/lib32
FAKEROOT_TARGET_SCRIPT:=$(FAKEROOT_DESTDIR)/bin/fakeroot
FAKEROOT_TARGET_BIARCH_LIB:=$(FAKEROOT_BIARCH_LD_PRELOAD_PATH)/libfakeroot-0.so

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit fakeroot support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# This doesn't affect sstrip because we build it on the host.
# The correct condition here would be:
# (using 32-bit toolchain) AND (any of the STRIP-options is selected) AND (host i 64-bit)
BIARCH_BUILD_SYSTEM:=$(and \
	$(or $(FREETZ_DOWNLOAD_TOOLCHAIN),$(FREETZ_TOOLCHAIN_32BIT)), \
	$(findstring $(shell uname -m),x86_64))

$(DL_DIR)/$(FAKEROOT_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FAKEROOT_SOURCE) $(FAKEROOT_SITE) $(FAKEROOT_SOURCE_MD5)

fakeroot-source: $(DL_DIR)/$(FAKEROOT_SOURCE)

$(FAKEROOT_DIR)/.unpacked: $(DL_DIR)/$(FAKEROOT_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$(FAKEROOT_SOURCE)
	$(SED) -i "s,getopt --version,getopt --version 2>/dev/null," \
		$(FAKEROOT_DIR)/scripts/fakeroot.in
	for i in $(FAKEROOT_MAKE_DIR)/patches/*.fakeroot.patch; do \
		$(PATCH_TOOL) $(FAKEROOT_DIR) $$i; \
	done
	touch $@

$(FAKEROOT_MAINARCH_DIR)/.configured: $(FAKEROOT_DIR)/.unpacked
	(mkdir -p $(FAKEROOT_MAINARCH_DIR); cd $(FAKEROOT_MAINARCH_DIR); $(RM) config.cache; \
		CFLAGS="-O3 -Wall" \
		CC="$(TOOLS_CC)" \
		../../configure \
		--prefix=$(FAKEROOT_DESTDIR) \
		--enable-shared \
		$(DISABLE_NLS) \
	);
	touch $@

$(FAKEROOT_TARGET_SCRIPT): $(FAKEROOT_MAINARCH_DIR)/.configured
	$(MAKE) -C $(FAKEROOT_MAINARCH_DIR) install
	$(SED) -i -e 's,^PATHS=.*,PATHS=$(FAKEROOT_MAINARCH_LD_PRELOAD_PATH)$(if $(BIARCH_BUILD_SYSTEM),:$(FAKEROOT_BIARCH_LD_PRELOAD_PATH)),g' $(FAKEROOT_TARGET_SCRIPT)

$(FAKEROOT_BIARCH_DIR)/.configured: $(FAKEROOT_DIR)/.unpacked
	(mkdir -p $(FAKEROOT_BIARCH_DIR); cd $(FAKEROOT_BIARCH_DIR); $(RM) config.cache; \
		CFLAGS="-m32 -O3 -Wall" \
		CC="$(TOOLS_CC)" \
		../../configure \
		--prefix=$(FAKEROOT_DESTDIR) \
		--enable-shared \
		$(DISABLE_NLS) \
	);
	touch $@

$(FAKEROOT_TARGET_BIARCH_LIB): $(FAKEROOT_BIARCH_DIR)/.configured
	$(MAKE) -C $(FAKEROOT_BIARCH_DIR) libdir="$(FAKEROOT_BIARCH_LD_PRELOAD_PATH)" install-libLTLIBRARIES

fakeroot: $(FAKEROOT_TARGET_SCRIPT) $(if $(BIARCH_BUILD_SYSTEM),$(FAKEROOT_TARGET_BIARCH_LIB))

fakeroot-clean:
	-$(MAKE) -C $(FAKEROOT_MAINARCH_DIR) clean
	-$(MAKE) -C $(FAKEROOT_BIARCH_DIR) clean

fakeroot-dirclean:
	$(RM) -r $(FAKEROOT_DIR)

fakeroot-distclean: fakeroot-dirclean
	$(RM) -r $(FAKEROOT_TARGET_SCRIPT) $(FAKEROOT_DESTDIR)/bin/faked $(FAKEROOT_DESTDIR)/lib*/libfakeroot*
