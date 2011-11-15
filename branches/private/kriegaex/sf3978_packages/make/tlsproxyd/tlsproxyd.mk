$(call PKG_INIT_BIN, 0.0.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=1a70db864e2ebefd517e081e2e056e4e
$(PKG)_SITE:=http://www.ex-parrot.com/~chris/$(pkg)/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := openssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(TLSPROXYD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -g -DTLSPROXYD_VERSION='\"$(VERSION)\"' \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-g -L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		LDLIBS="-lssl -lcrypto"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(TLSPROXYD_DIR) clean
	$(RM) $(TLSPROXYD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(TLSPROXYD_BINARIES_TARGET_DIR)

$(PKG_FINISH)
