$(call PKG_INIT_BIN, 2.1.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=3111a027907016c0902d67350c619df6
$(PKG)_SITE:=http://distfiles.macports.org/$(pkg)/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON := ncurses
$(PKG)_LIBS := -lncurses -lm

$(PKG)_CONFIGURE_OPTIONS += --disable-cnt-workaround \
			    --disable-dbi \
			    --disable-rrd \
			    --disable-asound

$(PKG)_CONFIGURE_ENV += ac_cv_lib_nl_nl_connect=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(BMON_DIR) \
			    LIBS="$(BMON_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BMON_DIR) clean
	 $(RM) $(BMON_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BMON_TARGET_BINARY)
	$(RM) $(BMON_BINARIES_TARGET_DIR)

$(PKG_FINISH)
