$(call PKG_INIT_BIN, 2.10)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=3b32d981d746abf8b0292c6ab01d10d4
$(PKG)_SITE:=http://download.m0k.org/transmission/files

$(PKG)_BINARIES_ALL_SHORT     := cli  daemon  remote  create  edit   show
$(PKG)_BINARIES_BUILD_SUBDIRS := cli/ daemon/ daemon/ utils/  utils/ utils/

$(PKG)_BINARIES_ALL           := $(addprefix transmission-,$($(PKG)_BINARIES_ALL_SHORT))
$(PKG)_BINARIES               := $(addprefix transmission-,$(if $(FREETZ_PACKAGE_TRANSMISSION_CLIENT),cli,) $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL_SHORT)))
$(PKG)_BINARIES_BUILD_DIR     := $(addprefix $($(PKG)_DIR)/, $(join $($(PKG)_BINARIES_BUILD_SUBDIRS),$($(PKG)_BINARIES_ALL)))
$(PKG)_BINARIES_TARGET_DIR    := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_WEBINTERFACE_DIR:=$($(PKG)_DIR)/web
$(PKG)_TARGET_WEBINTERFACE_DIR:=$($(PKG)_DEST_DIR)/usr/share/transmission-web-home
$(PKG)_TARGET_WEBINTERFACE_INDEX_HTML:=$($(PKG)_TARGET_WEBINTERFACE_DIR)/index.html

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
ifneq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_WEBINTERFACE)),y)
$(PKG)_NOT_INCLUDED += $($(PKG)_TARGET_WEBINTERFACE_DIR)
endif

$(PKG)_BUILD_PREREQ += intltool-update
$(PKG)_BUILD_PREREQ_HINT := Hint: on Debian-like systems this binary is provided by the intltool package

$(PKG)_DEPENDS_ON := zlib openssl curl libevent

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRANSMISSION_STATIC

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
# remove optimization & debug flags
$(PKG)_CONFIGURE_PRE_CMDS += $(foreach flag,-O[0-9] -g -ggdb3,$(SED) -i -r -e 's,(C(XX)?FLAGS="[^"]*)$(flag)(( [^"]*)?"),\1\3,g' ./configure;)
# silence '*LARGEFILE* redefined' warnings
$(PKG)_CONFIGURE_PRE_CMDS += find $(abspath $($(PKG)_DIR)) -type f -name "*.c" \
        -exec $(SED) -i -r -e 's|(\#define (_LARGEFILE(64)?_SOURCE))|\#ifndef \2\n\1\n\#endif|g' \{\} \+ ;
# silence 'inlining failed in call to foo: optimizing for size and code size would grow'-warnings
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,-Winline,,g' ./configure;

$(PKG)_CONFIGURE_OPTIONS += --disable-mac
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules

ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_STATIC)),y)
$(PKG)_LDFLAGS := -all-static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TRANSMISSION_DIR) \
		LDFLAGS="$(TARGET_LDFLAGS) $(TRANSMISSION_LDFLAGS)"

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$($(PKG)_TARGET_WEBINTERFACE_INDEX_HTML): $($(PKG)_DIR)/.unpacked
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_WEBINTERFACE)),y)
	mkdir -p $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)
	tar -c -C $(TRANSMISSION_WEBINTERFACE_DIR) --exclude=.svn --exclude=LICENSE --exclude='Makefile*' . | tar -x -C $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)
	chmod 644 $@
	touch $@
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_TARGET_WEBINTERFACE_INDEX_HTML)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TRANSMISSION_DIR) clean

$(pkg)-uninstall:
	$(RM) -r \
		$(TRANSMISSION_BINARIES_ALL:%=$(TRANSMISSION_DEST_DIR)/usr/bin/%) \
		$(TRANSMISSION_TARGET_WEBINTERFACE_DIR)

$(PKG_FINISH)
