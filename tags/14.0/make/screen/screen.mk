SCREEN_VERSION:=4.0.2
SCREEN_SOURCE:=screen-$(SCREEN_VERSION).tar.gz
SCREEN_SITE:=http://ftp.gnu.org/gnu/screen
SCREEN_DIR:=$(SOURCE_DIR)/screen-$(SCREEN_VERSION)
SCREEN_MAKE_DIR:=$(MAKE_DIR)/screen
SCREEN_TARGET_DIR:=$(PACKAGES_DIR)/screen-$(SCREEN_VERSION)/root/usr/bin
SCREEN_TARGET_BINARY:=screen
SCREEN_PKG_VERSION:=0.1
SCREEN_PKG_SOURCE:=screen-$(SCREEN_VERSION)-dsmod-$(SCREEN_PKG_VERSION).tar.bz2
SCREEN_PKG_SITE:=http://www.eiband.info/dsmod


$(DL_DIR)/$(SCREEN_SOURCE):
	wget -P $(DL_DIR) $(SCREEN_SITE)/$(SCREEN_SOURCE)

$(DL_DIR)/$(SCREEN_PKG_SOURCE):
	@wget -P $(DL_DIR) $(SCREEN_PKG_SITE)/$(SCREEN_PKG_SOURCE)

$(SCREEN_DIR)/.unpacked: $(DL_DIR)/$(SCREEN_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(SCREEN_SOURCE)
	for i in $(SCREEN_MAKE_DIR)/patches/*.patch; do \
		patch -d $(SCREEN_DIR) -p0 < $$i; \
	done
	touch $@

$(SCREEN_DIR)/.configured: $(SCREEN_DIR)/.unpacked ncurses
	( cd $(SCREEN_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../lib -L$(TARGET_MAKE_PATH)/../usr/lib -static-libgcc" \
		$(foreach flag,rename fchmod fchown strerror lstat _exit utimes vsnprintf getcwd setlocale strftime,ac_cv_func_$(flag)=yes ) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		--enable-shared \
		--disable-static \
		--disable-socket-dir \
		--with-sys-screenrc=/mod/etc/screenrc \
	);
	touch $@

$(SCREEN_DIR)/$(SCREEN_TARGET_BINARY): $(SCREEN_DIR)/.configured
	PATH="$(TARGET_PATH)" make -C $(SCREEN_DIR)

$(PACKAGES_DIR)/.screen-$(SCREEN_VERSION): $(DL_DIR)/$(SCREEN_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(SCREEN_PKG_SOURCE)
	@touch $@

screen: $(PACKAGES_DIR)/.screen-$(SCREEN_VERSION)

screen-package: $(PACKAGES_DIR)/.screen-$(SCREEN_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(SCREEN_PKG_SOURCE) screen-$(SCREEN_VERSION)

screen-precompiled: $(SCREEN_DIR)/$(SCREEN_TARGET_BINARY) screen
	$(TARGET_STRIP) $(SCREEN_DIR)/$(SCREEN_TARGET_BINARY)
	cp $(SCREEN_DIR)/$(SCREEN_TARGET_BINARY) $(SCREEN_TARGET_DIR)/$(SCREEN_TARGET_BINARY).bin

screen-source: $(SCREEN_DIR)/.unpacked $(PACKAGES_DIR)/.screen-$(SCREEN_VERSION)

screen-clean:
	-$(MAKE) -C $(SCREEN_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(SCREEN_PKG_SOURCE)

screen-dirclean:
	rm -rf $(SCREEN_DIR)
	rm -rf $(PACKAGES_DIR)/screen-$(SCREEN_VERSION)
	rm -f $(PACKAGES_DIR)/.screen-$(SCREEN_VERSION)

screen-list:
ifeq ($(strip $(DS_PACKAGE_SCREEN)),y)
	@echo "S99screen-$(SCREEN_VERSION)" >> .static
else
	@echo "S99screen-$(SCREEN_VERSION)" >> .dynamic
endif
