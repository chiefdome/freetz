######################################################################
#
# common part
#
######################################################################
GDB_VERSION:=$(TARGET_TOOLCHAIN_GDB_VERSION)
GDB_SITE:=@GNU/gdb
GDB_SOURCE:=gdb-$(GDB_VERSION).tar.bz2
GDB_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdb-$(GDB_VERSION)
GDB_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/gdb
GDB_DESTDIR:=$(TARGET_UTILS_DIR)/usr/bin

GDB_MD5_6.6 := a4df41d28dd514d64e8ccbfe125fd9a6
GDB_MD5_6.8 := c9da266b884fb8fa54df786dfaadbc7a
GDB_MD5_7.2 := 64260e6c56979ee750a01055f16091a5
GDB_MD5     := $(GDB_MD5_$(GDB_VERSION))

$(GDB_DESTDIR):
	mkdir -p $@

gdb-source: $(DL_DIR)/$(GDB_SOURCE)
$(DL_DIR)/$(GDB_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(GDB_SOURCE) $(GDB_SITE) $(GDB_MD5)

gdb-unpacked: $(GDB_DIR)/.unpacked
$(GDB_DIR)/.unpacked: $(DL_DIR)/$(GDB_SOURCE) | $(TARGET_TOOLCHAIN_DIR)
	$(RM) -r $(GDB_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(GDB_SOURCE)

	set -e; \
	for i in $(GDB_MAKE_DIR)/$(GDB_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(GDB_DIR) $$i; \
	done
	touch $@

######################################################################
#
# gdb for target
#
######################################################################
GDB_TARGET_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdb-$(GDB_VERSION)-target
GDB_TARGET_BINARY_BUILDDIR:=$(GDB_TARGET_DIR)/gdb/gdb
GDB_TARGET_BINARY_DESTDIR:=$(GDB_DESTDIR)/gdb

GDB_TARGET_CONFIGURE_VARS := \
	ac_cv_type_uintptr_t=yes \
	gt_cv_func_gettext_libintl=yes \
	ac_cv_func_dcgettext=yes \
	gdb_cv_func_sigsetjmp=yes \
	bash_cv_func_strcoll_broken=no \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_func_sigsetjmp=present \
	bash_cv_have_mbstate_t=yes

#TODO: ENABLE_LOCALE & DISABLE_GDBMI are never set
$(GDB_TARGET_DIR)/.configured: $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_TARGET_DIR)
	(cd $(GDB_TARGET_DIR); PATH=$(TARGET_PATH) \
		gdb_cv_func_sigsetjmp=yes \
		$(TARGET_CONFIGURE_ENV) \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS)" \
		CPPFLAGS_FOR_TARGET="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS_FOR_TARGET="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		$(GDB_TARGET_CONFIGURE_VARS) \
		$(GDB_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--prefix=/usr \
		$(DISABLE_NLS) \
		--without-uiout \
		$(DISABLE_GDBMI) \
		--disable-tui \
		--disable-gdbtk \
		--without-x \
		--disable-sim \
		--enable-gdbserver \
		--without-included-gettext \
		--enable-threads \
		--disable-werror \
		$(QUIET) \
	);
ifeq ($(ENABLE_LOCALE),true)
	-$(SED) "s,^INTL *=.*,INTL = -lintl,g;" $(GDB_DIR)/gdb/Makefile
endif
	touch $@

$(GDB_TARGET_BINARY_BUILDDIR): $(GDB_TARGET_DIR)/.configured
	$(MAKE_ENV) \
		$(MAKE) -C $(GDB_TARGET_DIR) \
		CC=$(TARGET_CC) \
		MT_CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS=""

$(GDB_TARGET_BINARY_DESTDIR): $(GDB_TARGET_BINARY_BUILDDIR) | $(GDB_DESTDIR)
	$(INSTALL_BINARY_STRIP)

gdbtarget: ncurses-precompiled $(GDB_TARGET_BINARY_DESTDIR)

gdbtarget-source: $(DL_DIR)/$(GDB_SOURCE)

gdbtarget-clean:
	-$(MAKE) -C $(GDB_DIR) clean

gdbtarget-uninstall:
	$(RM) $(GDB_TARGET_BINARY_DESTDIR)

gdbtarget-dirclean: gdbtarget-uninstall
	$(RM) -r $(GDB_DIR)

######################################################################
#
# gdbserver for target
#
######################################################################
GDB_SERVER_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdbserver-$(GDB_VERSION)
GDB_SERVER_BINARY_BUILDDIR:=$(GDB_SERVER_DIR)/gdbserver
GDB_SERVER_BINARY_DESTDIR:=$(GDB_DESTDIR)/gdbserver

$(GDB_SERVER_DIR)/.configured: $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_SERVER_DIR)
	(cd $(GDB_SERVER_DIR); PATH=$(TARGET_PATH) \
		$(TARGET_CONFIGURE_ENV) \
		gdb_cv_func_sigsetjmp=yes \
		bash_cv_have_mbstate_t=yes \
		$(GDB_DIR)/gdb/gdbserver/configure \
		--cache-file=/dev/null \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		--includedir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include \
		$(DISABLE_NLS) \
		--without-uiout \
		$(DISABLE_GDBMI) \
		--disable-tui \
		--disable-gdbtk \
		--without-x \
		--without-included-gettext \
	);
	touch $@

$(GDB_SERVER_BINARY_BUILDDIR): $(GDB_SERVER_DIR)/.configured
	$(MAKE_ENV) \
		$(MAKE) -C $(GDB_SERVER_DIR) \
		CC=$(TARGET_CC) \
		MT_CFLAGS="$(TARGET_CFLAGS)"

$(GDB_SERVER_BINARY_DESTDIR): $(GDB_SERVER_BINARY_BUILDDIR) | $(GDB_DESTDIR)
	$(INSTALL_BINARY_STRIP)

gdbserver: $(GDB_SERVER_BINARY_DESTDIR)

gdbserver-clean:
	-$(MAKE) -C $(GDB_SERVER_DIR) clean

gdbserver-uninstall:
	$(RM) $(GDB_SERVER_BINARY_DESTDIR)

gdbserver-dirclean: gdbserver-uninstall
	$(RM) -r $(GDB_SERVER_DIR)

######################################################################
#
# gdb for host
#
######################################################################
GDB_HOST_DIR:=$(TARGET_TOOLCHAIN_DIR)/gdbhost-$(GDB_VERSION)
GDB_HOST_BINARY_BUILDDIR:=$(GDB_HOST_DIR)/gdb/gdb
GDB_HOST_BINARY_DESTDIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(TARGET_CROSS)gdb

$(GDB_HOST_DIR)/.configured: $(GDB_DIR)/.unpacked
	mkdir -p $(GDB_HOST_DIR)
	(cd $(GDB_HOST_DIR); PATH=$(TARGET_PATH) \
		gdb_cv_func_sigsetjmp=yes \
		bash_cv_have_mbstate_t=yes \
		$(GDB_DIR)/configure \
		--cache-file=/dev/null \
		--prefix=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		$(DISABLE_NLS) \
		--without-uiout $(DISABLE_GDBMI) \
		--disable-tui --disable-gdbtk --without-x \
		--without-included-gettext \
		--enable-threads \
		--disable-werror \
	);
	touch $@

$(GDB_HOST_BINARY_BUILDDIR): $(GDB_HOST_DIR)/.configured
	$(MAKE) -C $(GDB_HOST_DIR)
	strip $(GDB_HOST_BINARY_BUILDDIR)

$(GDB_HOST_BINARY_DESTDIR): $(GDB_HOST_BINARY_BUILDDIR)
	$(INSTALL_FILE)
	ln -sf $(TARGET_CROSS)gdb $(dir $@)/$(GNU_TARGET_NAME)-gdb

gdbhost: $(GDB_HOST_BINARY_DESTDIR)

gdbhost-clean:
	-$(MAKE) -C $(GDB_HOST_DIR) clean

gdbhost-uninstall:
	$(RM) $(GDB_HOST_BINARY_DESTDIR)

gdbhost-dirclean: gdbhost-uninstall
	$(RM) -r $(GDB_HOST_DIR)

gdb: uclibc $(GDB_TARGETS)

gdb-clean: gdbhost-clean gdbserver-clean gdbtarget-clean

gdb-dirclean: gdbhost-dirclean gdbserver-dirclean gdbtarget-dirclean

.PHONY: \
	gdb gdb-source gdb-unpacked gdb-patched \
	gdbtarget gdbtarget-clean gdbtarget-uninstall gdbtarget-dirclean \
	gdbserver gdbserver-clean gdbserver-uninstall gdbserver-dirclean \
	gdbhost gdbhost-clean gdbhost-uninstall gdbhost-dirclean