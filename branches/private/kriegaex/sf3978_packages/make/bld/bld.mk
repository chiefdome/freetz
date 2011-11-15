$(call PKG_INIT_BIN, 0.3.4.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=3bcf5031cad265f84bfc4e567cd6c7d2
$(PKG)_SITE:=http://bld.r14.freenix.org/Home/Download/

$(PKG)_BINARIES:=bld bldread bldsubmit
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

BLD_LIBS := -lresolv -lnsl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BLD_DIR) \
	LIBS="$(BLD_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BLD_DIR) clean
	$(RM) $(BLD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(BLD_BINARIES_TARGET_DIR)

$(PKG_FINISH)
