$(call PKG_INIT_BIN, 7.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=45e7c3229a94d19abb5d92daa36c61d9
$(PKG)_SITE:=http://www.$(pkg)-webserver.org/files/
#
$(PKG)_BINARIES_ALL := $(pkg) wigwam ssi-cgi php-fcgi cgi-wrapper
# hiawatha is always included
$(PKG)_BINARIES := $(pkg) $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL),WITH)
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
#
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
#
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HIAWATHA_WITH_CHROOT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HIAWATHA_WITH_COMMAND
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HIAWATHA_WITH_CACHE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HIAWATHA_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HIAWATHA_WITH_IPV6
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HIAWATHA_WITH_TOOLKIT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HIAWATHA_WITH_MONITOR
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HIAWATHA_WITH_XSLT
#
ifeq ($(strip $(FREETZ_PACKAGE_HIAWATHA_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif
#
ifeq ($(strip $(FREETZ_PACKAGE_HIAWATHA_WITH_XSLT)),y)
$(PKG)_DEPENDS_ON += xsltproc
$(PKG)_LIBS_1 := -lxml2
$(PKG)_LIBS_2 := -lxslt
endif
#
$(PKG)_DEPENDS_ON += zlib
#
$(PKG)_CONFIGURE_OPTIONS += --disable-largefile
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_HIAWATHA_WITH_COMMAND),--enable-command,--disable-command)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_HIAWATHA_WITH_CHROOT),--enable-chroot,--disable-chroot)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_HIAWATHA_WITH_CACHE),--enable-cache,--disable-cache)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_HIAWATHA_WITH_IPV6),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_HIAWATHA_WITH_SSL),--enable-ssl,--disable-ssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_HIAWATHA_WITH_TOOLKIT),--enable-toolkit,--disable-toolkit)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_HIAWATHA_WITH_XSLT),--enable-xslt,--disable-xslt)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_HIAWATHA_WITH_MONITOR),--enable-monitor,--disable-monitor)

$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_urandom=yes
$(PKG)_CONFIGURE_ENV += webrootdir=/var/media/ftp/uStor01/www

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(HIAWATHA_DIR) \
		LIBXML="$(HIAWATHA_LIBS_1)" \
		LIBXSLT="$(HIAWATHA_LIBS_2)" \
		LIBZ="-lz"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(HIAWATHA_DIR) clean
	$(RM) $(HIAWATHA_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HIAWATHA_BINARIES_ALL:%=$(HIAWATHA_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
