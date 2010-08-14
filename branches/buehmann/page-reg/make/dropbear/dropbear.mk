$(call PKG_INIT_BIN, 0.52)
$(PKG)_SOURCE:=dropbear-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://matt.ucc.asn.au/dropbear/releases
$(PKG)_BINARY:=$($(PKG)_DIR)/dropbearmulti
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dropbearmulti
$(PKG)_STARTLEVEL=30
$(PKG)_SOURCE_MD5:=a1fc7adf601bca53330a792a9c873439

ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_SERVER_ONLY)),y)
$(PKG)_MAKE_OPTIONS:=PROGRAMS="dropbear dropbearkey" MULTI=1
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,ssh scp)
else
$(PKG)_MAKE_OPTIONS:=PROGRAMS="dropbear dbclient dropbearkey scp" MULTI=1 SCPPROGRESS=1
endif

$(PKG)_CPPFLAGS:=
ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_SFTP_SERVER)),y)
$(PKG)_CPPFLAGS+=-DSFTPSERVER_PATH='\"/usr/lib/sftp-server\"'
endif
ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_DISABLE_HOST_LOOKUP)),y)
$(PKG)_CPPFLAGS+=-DNO_HOST_LOOKUP
endif

ifeq ($(strip $(FREETZ_PACKAGE_DROPBEAR_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON := zlib
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_SERVER_ONLY
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_SFTP_SERVER
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DROPBEAR_DISABLE_HOST_LOOKUP

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_DROPBEAR_WITH_ZLIB),,--disable-zlib)
$(PKG)_CONFIGURE_OPTIONS += --disable-pam
$(PKG)_CONFIGURE_OPTIONS += --enable-openpty
$(PKG)_CONFIGURE_OPTIONS += --enable-syslog
$(PKG)_CONFIGURE_OPTIONS += --enable-shadow
$(PKG)_CONFIGURE_OPTIONS += --disable-lastlog
$(PKG)_CONFIGURE_OPTIONS += --disable-utmp
$(PKG)_CONFIGURE_OPTIONS += --disable-utmpx
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmp
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmpx
$(PKG)_CONFIGURE_OPTIONS += --disable-loginfunc
$(PKG)_CONFIGURE_OPTIONS += --disable-pututline
$(PKG)_CONFIGURE_OPTIONS += --disable-pututxline

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DROPBEAR_DIR) \
		$(DROPBEAR_MAKE_OPTIONS) CPPFLAGS="$(DROPBEAR_CPPFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DROPBEAR_DIR) clean
	$(RM) $(DROPBEAR_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(DROPBEAR_TARGET_BINARY)

$(PKG_FINISH)
