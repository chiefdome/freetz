$(call PKG_INIT_BIN, 5.0.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://tukaani.org/$(pkg)/
$(PKG)_SOURCE_MD5:=8d900b742b94fa9e708ca4f5a4b29003

$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/$(pkg)/.libs/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIBS:=liblzma.so.5.0.3
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DIR)/src/liblzma/.libs/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%)

$(call REPLACE_LIBTOOL)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_OPTIONS += --enable-encoders=lzma1,lzma2,delta,x86,arm \
			    --enable-decoders=lzma1,lzma2,delta,x86,arm \
			    --disable-assembler \
			    --enable-small \
			    --disable-xzdec \
			    --disable-lzmadec \
			    --disable-lzmainfo \
			    --disable-lzma-links \
			    --disable-scripts \
			    --disable-largefile \
			    --without-libiconv-prefix \
			    --without-libintl-prefix \
			    --disable-option-checking \
			    --enable-assume-ram=8

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(XZ_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/$(pkg)/.libs/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/src/liblzma/.libs/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(XZ_DIR) clean
	$(RM) $(XZ_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(XZ_BINARIES_TARGET_DIR) $(XZ_LIBS_TARGET_DIR)

$(PKG_FINISH)
