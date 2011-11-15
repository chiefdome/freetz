$(call PKG_INIT_BIN, 0.13)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_SOURCE_MD5:=4bd205e203ef18f0a0c06ce7f8f5daca
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/w/$(pkg)
$(PKG)_BINARIES:=$(pkg) cgi_wrapper/$(pkg)_cgi_wrapper
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_OPTIONS += --disable-option-checking \
			    --disable-largefile

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(WEBORF_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(WEBORF_DIR) clean
	$(RM) $(WEBORF_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(WEBORF_BINARIES_TARGET_DIR)

$(PKG_FINISH)
