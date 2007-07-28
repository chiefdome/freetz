# Makefile for to build a gcc/uClibc toolchain
#
# Copyright (C) 2002-2003 Erik Andersen <andersen@uclibc.org>
# Copyright (C) 2004 Manuel Novoa III <mjn3@uclibc.org>
# Copyright (C) 2006 Daniel Eiband <eiband@online.de> 
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

GCC_VERSION:=$(TARGET_TOOLCHAIN_GCC_VERSION)
GCC_SOURCE:=gcc-$(GCC_VERSION).tar.bz2
GCC_SITE:=ftp://gcc.gnu.org/pub/gcc/releases/gcc-$(GCC_VERSION)
GCC_DIR:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)
GCC_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/gcc
GCC_BUILD_DIR1:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-initial
GCC_BUILD_DIR2:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-final

ifeq ($(strip $(DS_TARGET_GXX)),y)
GCC_TARGET_LANGUAGES:=c,c++
else
GCC_TARGET_LANGUAGES:=c
endif

GCC_STRIP_HOST_BINARIES:=true
GCC_USE_SJLJ_EXCEPTIONS:=--enable-sjlj-exceptions
GCC_SHARED_LIBGCC:=--enable-shared
GCC_EXTRA_CONFIG_OPTIONS:=--with-float=soft --enable-cxx-flags=-msoft-float

$(DL_DIR)/$(GCC_SOURCE): | $(DL_DIR)
	wget --passive-ftp -P $(DL_DIR) $(GCC_SITE)/$(GCC_SOURCE)

$(GCC_DIR)/.unpacked: $(DL_DIR)/$(GCC_SOURCE)
	mkdir -p $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(GCC_SOURCE)
	for i in $(GCC_MAKE_DIR)/$(GCC_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(GCC_DIR) $$i 1; \
	done
	touch $@

##############################################################################
#
#   initial gcc
#
##############################################################################

$(GCC_BUILD_DIR1)/.configured: $(GCC_DIR)/.unpacked
	mkdir -p $(GCC_BUILD_DIR1)
	( cd $(GCC_BUILD_DIR1); PATH=$(TARGET_TOOLCHAIN_PATH) \
		CC="$(HOSTCC)" \
		$(GCC_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=c \
		--disable-shared \
		--with-sysroot=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		--disable-__cxa_atexit \
		--enable-target-optspace \
		--with-gnu-ld \
		--disable-libmudflap \
		$(DISABLE_NLS) \
		$(GCC_EXTRA_CONFIG_OPTIONS) \
	);
	### not in buildroot, what does this do?
	mkdir -p $(GCC_BUILD_DIR1)/gcc
	cp $(GCC_DIR)/gcc/defaults.h $(GCC_BUILD_DIR1)/gcc/defaults.h
	$(SED) -i -e 's/\.eh_frame/.text/' $(GCC_BUILD_DIR1)/gcc/defaults.h
	touch $@

$(GCC_BUILD_DIR1)/.compiled: $(GCC_BUILD_DIR1)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(GCC_BUILD_DIR1) all-gcc
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-gcc: $(GCC_BUILD_DIR1)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(GCC_BUILD_DIR1) install-gcc

gcc_initial: uclibc-configured binutils $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-gcc

gcc_initial-clean:
	rm -rf $(GCC_BUILD_DIR1)

gcc_initial-dirclean:
	rm -rf $(GCC_BUILD_DIR1) $(GCC_DIR)

##############################################################################
#
#   final gcc
#
##############################################################################

$(GCC_BUILD_DIR2)/.configured: $(GCC_DIR)/.unpacked
	mkdir -p $(GCC_BUILD_DIR2)
	# Important!  Required for limits.h to be fixed.
	ln -sf ../include $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/sys-include
	( cd $(GCC_BUILD_DIR2); PATH=$(TARGET_TOOLCHAIN_PATH) \
		CC="$(HOSTCC)" \
		$(GCC_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=$(GCC_TARGET_LANGUAGES) \
		--disable-__cxa_atexit \
		--enable-target-optspace \
		--with-gnu-ld \
		--disable-libmudflap \
		$(GCC_SHARED_LIBGCC) \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		$(GCC_USE_SJLJ_EXCEPTIONS) \
		$(GCC_EXTRA_CONFIG_OPTIONS) \
	);
	touch $@

$(GCC_BUILD_DIR2)/.compiled: $(GCC_BUILD_DIR2)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(GCC_BUILD_DIR2) all
	touch $(GCC_BUILD_DIR2)/.compiled

$(GCC_BUILD_DIR2)/.installed: $(GCC_BUILD_DIR2)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(GCC_BUILD_DIR2) install
	# Strip the host binaries
ifeq ($(GCC_STRIP_HOST_BINARIES),true)
	-strip --strip-all -R .note -R .comment $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/*
endif
	# Set up the symlinks to enable lying about target name.
	set -e; \
	( cd $(TARGET_TOOLCHAIN_STAGING_DIR); \
		ln -sf $(REAL_GNU_TARGET_NAME) $(GNU_TARGET_NAME); \
		cd bin; \
		for app in $(REAL_GNU_TARGET_NAME)-* ; do \
			ln -sf $${app} \
		   	$(GNU_TARGET_NAME)$${app##$(REAL_GNU_TARGET_NAME)}; \
		done; \
	);
	touch $(GCC_BUILD_DIR2)/.installed

gcc: uclibc-configured binutils gcc_initial uclibc $(ROOT_DIR)/lib/libgcc_s.so.1 $(GCC_BUILD_DIR2)/.installed

gcc-source: $(DL_DIR)/$(GCC_SOURCE)

gcc-clean:
	rm -rf $(GCC_BUILD_DIR2)
	for prog in cpp gcc gcc-[0-9]* protoize unprotoize gcov gccbug cc; do \
	    rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-$$prog \
	    rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-$$prog; \
	done

gcc-dirclean: gcc_initial-dirclean
	rm -rf $(GCC_BUILD_DIR2)

.PHONY: gcc gcc_initial
