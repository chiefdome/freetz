$(call PKG_INIT_BIN, 0.5.20)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=0161abaec3658095044601eae82bbc5b
$(PKG)_SITE:=http://www.fpx.de/fp/Software/UUDeview/download/
$(PKG)_BINARIES:=uuenview $(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/unix/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIBS:=libuu.so.$($(PKG)_VERSION)
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DIR)/uulib/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --disable-minews
$(PKG)_CONFIGURE_OPTIONS += --disable-manuals
$(PKG)_CONFIGURE_OPTIONS += --disable-tcl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(UUDEVIEW_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/unix/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/uulib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(UUDEVIEW_DIR) clean
	$(RM) $(UUDEVIEW_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UUDEVIEW_BINARIES_TARGET_DIR) $(UUDEVIEW_LIBS_TARGET_DIR)

$(PKG_FINISH)
