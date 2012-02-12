$(call PKG_INIT_BIN, 2.4.5)
$(PKG)_SOURCE:=ppp-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=4621bc56167b6953ec4071043fe0ec57
$(PKG)_SITE:=ftp://ftp.samba.org/pub/ppp
$(PKG)_STARTLEVEL=81

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/ppp-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/pppd/pppd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/pppd
$(PKG)_CHAT_BINARY:=$(PPPD_DIR)/chat/chat
$(PKG)_CHAT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/chat
ifneq ($(strip $(FREETZ_PACKAGE_PPPD_CHAT)),y)
$(PKG)_NOT_INCLUDED := $($(PKG)_CHAT_TARGET_BINARY)
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
ifeq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_CFLAGS := -DFREETZ_TARGET_IPV6_SUPPORT
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_CHAT_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PPPD_DIR) \
		CC="$(TARGET_CC)" \
		COPTS="$(TARGET_CFLAGS) $(PPPD_CFLAGS)" \
		STAGING_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_CHAT_TARGET_BINARY): $($(PKG)_CHAT_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_PPPD_CHAT)),y)
	$(INSTALL_BINARY_STRIP)
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_CHAT_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PPPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PPPD_TARGET_BINARY) $(PPPD_CHAT_TARGET_BINARY)

$(PKG_FINISH)