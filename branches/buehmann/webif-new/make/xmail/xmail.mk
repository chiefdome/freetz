$(call PKG_INIT_BIN, 1.27)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.xmailserver.org
$(PKG)_BINARY:=$($(PKG)_DIR)/bin/XMail
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/MailRoot/bin/XMail
$(PKG)_SOURCE_MD5:=73c9d95012709d7b11511dfb6dd6ab3d

$(PKG)_DEPENDS_ON := uclibcxx
$(PKG)_LDFLAGS := -ldl -lpthread
$(PKG)_CFLAGS := -I$(XMAIL_DIR) -D__LINUX__ -DSYS_HAS_SENDFILE -D_REENTRANT=1 -D_THREAD_SAFE=1 -DHAS_SYSMACHINE -D_GNU_SOURCE -D_POSIX_PTHREAD_SEMANTICS

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_XMAIL_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_XMAIL_WITH_SSL

ifeq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_CFLAGS += -DIPV6
endif

ifeq ($(strip $(FREETZ_PACKAGE_XMAIL_STATIC)),y)
$(PKG)_LDFLAGS += -static
endif
ifeq ($(strip $(FREETZ_PACKAGE_XMAIL_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_LDFLAGS += -lssl -lcrypto
$(PKG)_CFLAGS += -DWITH_SSL
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(XMAIL_DIR) -f Makefile.lnx \
		CC="$(TARGET_CXX)" \
		LD="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS) $(XMAIL_CFLAGS)" \
		LDFLAGS="$(TARGED_LDFLAGS) $(XMAIL_LDFLAGS)" \
		STRIP="$(TARGET_STRIP)"
	$(TARGET_CC) -Wall -O2 -o $(XMAIL_DIR)/bin/compartment $(XMAIL_DIR)/docs/compartment.c

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	rm -rf $(XMAIL_DEST_DIR)/usr/lib/MailRoot
	mkdir -p $(XMAIL_DEST_DIR)/usr/lib/MailRoot/bin/
	for i in $$(find $(XMAIL_DIR)/bin/ -type f -executable); do \
		cp $$i $(XMAIL_DEST_DIR)/usr/lib/MailRoot/bin/; \
	done
	rm -rf $(XMAIL_DEST_DIR)/etc/default.xmail/default_config/
	mkdir -p $(XMAIL_DEST_DIR)/etc/default.xmail/default_config/

	tar --exclude='./bin' --exclude='./domains/*' -C $(XMAIL_DIR)/MailRoot -cf \
		$(XMAIL_DEST_DIR)/etc/default.xmail/default_config/default_config.tar .

	for i in $$(find $(XMAIL_DEST_DIR)/usr/lib/MailRoot/bin -type f -executable); do \
		$(TARGET_STRIP) $$i; \
	done

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(XMAIL_DIR) clean
	$(RM) $(XMAIL_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(XMAIL_TARGET_BINARY)

$(PKG_FINISH)
