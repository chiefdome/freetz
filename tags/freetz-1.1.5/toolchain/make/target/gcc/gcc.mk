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
GCC_BUILD_DIR3:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-target

ifeq ($(strip $(FREETZ_TARGET_GXX)),y)
GCC_TARGET_LANGUAGES:=c,c++
else
GCC_TARGET_LANGUAGES:=c
endif

ifeq ($(strip $(FREETZ_STATIC_TOOLCHAIN)),y)
GCC_EXTRA_MAKE_OPTIONS:="LDFLAGS=-static"
else
GCC_EXTRA_MAKE_OPTIONS:=
endif

GCC_STRIP_HOST_BINARIES:=true
GCC_USE_SJLJ_EXCEPTIONS:=--enable-sjlj-exceptions
GCC_SHARED_LIBGCC:=--enable-shared
GCC_EXTRA_CONFIG_OPTIONS:=--with-float=soft --enable-cxx-flags=-msoft-float

$(DL_DIR)/$(GCC_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(GCC_SOURCE) $(GCC_SITE)

$(GCC_DIR)/.unpacked: $(DL_DIR)/$(GCC_SOURCE)
	mkdir -p $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(GCC_SOURCE)
	for i in $(GCC_MAKE_DIR)/$(GCC_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(GCC_DIR) $$i; \
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
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR1) all-gcc
	touch $@

gcc_initial=$(GCC_BUILD_DIR1)/.installed
$(gcc_initial) $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-gcc: $(GCC_BUILD_DIR1)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(GCC_BUILD_DIR1) install-gcc
	touch $(gcc_initial)

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
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR2) all
	touch $@

$(GCC_BUILD_DIR2)/.installed: $(GCC_BUILD_DIR2)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(GCC_BUILD_DIR2) install
	# Strip the host binaries
ifeq ($(GCC_STRIP_HOST_BINARIES),true)
	-strip --strip-all -R .note -R .comment $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-*
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
	touch $@

cross_compiler:=$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-gcc
cross_compiler gcc: uclibc-configured binutils gcc_initial uclibc \
	$(GCC_BUILD_DIR2)/.installed $(ROOT_DIR)/lib/libgcc_s.so.1

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

#############################################################
#
# Next build target gcc compiler
#
#############################################################
$(GCC_BUILD_DIR3)/.configured: $(GCC_BUILD_DIR2)/.installed
	mkdir -p $(GCC_BUILD_DIR3)
	( cd $(GCC_BUILD_DIR3); rm -rf config.cache; \
		GCC="$(TARGET_CC)" \
		CFLAGS_FOR_BUILD="-g -O2 $(HOST_CFLAGS)" \
		$(TARGET_CONFIGURE_OPTS) \
		$(GCC_DIR)/configure \
		--prefix=/usr \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=$(GCC_TARGET_LANGUAGES) \
		--with-gxx-include-dir=/usr/include/c++ \
		--disable-__cxa_atexit \
		--with-gnu-ld \
		--disable-libmudflap \
		--enable-threads \
		$(GCC_SHARED_LIBGCC) \
		$(DISABLE_NLS) \
		$(GCC_USE_SJLJ_EXCEPTIONS) \
		$(DISABLE_LARGEFILE) \
		$(GCC_EXTRA_CONFIG_OPTIONS) \
	);
	touch $@

$(GCC_BUILD_DIR3)/.compiled: $(GCC_BUILD_DIR3)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C$(GCC_BUILD_DIR3) all
	touch $@

REAL_GCC_VERSION=$(shell cat $(GCC_DIR)/gcc/BASE-VER)
GCC_LIB_SUBDIR=libexec/gcc/$(REAL_GNU_TARGET_NAME)/$(REAL_GCC_VERSION)

$(TARGET_UTILS_DIR)/usr/bin/gcc: $(GCC_BUILD_DIR3)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) DESTDIR=$(TARGET_UTILS_DIR) \
		$(MAKE1) -C $(GCC_BUILD_DIR3) install
	if [ ! -e $(TARGET_UTILS_DIR)/include ]; then \
		ln -s $(TARGET_TOOLCHAIN_STAGING_DIR)/include $(TARGET_UTILS_DIR)/include; \
	fi
	# Remove broken specs file (cross compile flag is set).
	rm -f $(TARGET_UTILS_DIR)/usr/$(GCC_LIB_SUBDIR)/specs

	-(cd $(TARGET_UTILS_DIR)/usr/bin && find -type f | xargs $(TARGET_STRIP) )
	-(cd $(TARGET_UTILS_DIR)/usr/$(GCC_LIB_SUBDIR) && $(TARGET_STRIP) cc1 cc1plus collect2 > /dev/null 2>&1)
	-(cd $(TARGET_UTILS_DIR)/usr/lib && $(TARGET_STRIP) libstdc++.so.*.*.* > /dev/null 2>&1)

	rm -f $(TARGET_UTILS_DIR)/usr/lib/*.la*
	rm -rf $(TARGET_UTILS_DIR)/share/locale $(TARGET_UTILS_DIR)/usr/info \
		$(TARGET_UTILS_DIR)/usr/man $(TARGET_UTILS_DIR)/usr/share/doc
	# Make sure we have 'cc'.
	if [ ! -e $(TARGET_UTILS_DIR)/usr/bin/cc ]; then \
		ln -snf gcc $(TARGET_UTILS_DIR)/usr/bin/cc; \
	fi
	# These are in /lib, so...
	rm -rf $(TARGET_UTILS_DIR)/usr/lib/libgcc_s*.so*
	touch -c $@

gcc_target: uclibc binutils $(TARGET_UTILS_DIR)/usr/bin/gcc

gcc_target-clean:
	rm -rf $(GCC_BUILD_DIR3)
	rm -f $(TARGET_UTILS_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)*

gcc_target-dirclean:
	rm -rf $(GCC_BUILD_DIR3)
