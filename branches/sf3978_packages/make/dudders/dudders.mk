$(call PKG_INIT_BIN, 1.04)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_SOURCE_MD5:=1d368a86f3c284e95d260a94767a8ded
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_LIBS:=crypt_gcrypt.so crypt_openssl.so
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DIR)/.libs/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
EXTRA_CFLAGS:=-DNDEBUG -std=gnu99
$(PKG)_DEPENDS_ON := openssl libgcrypt
$(PKG)_LIBS := -lssl -lcrypto -lgcrypt
$(PKG)_CONFIGURE_OPTIONS += --with-libgcrypt-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-dlcrypto="openssl gcrypt"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DUDDERS_DIR) \
	CFLAGS="$(EXTRA_CFLAGS) $(TARGET_CFLAGS)" \
	LIBS="$(DUDDERS_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)
$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/.libs/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DUDDERS_DIR) clean
	$(RM) $(DUDDERS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DUDDERS_BINARIES_TARGET_DIR) 
	      $(DUDDERS_LIBS_TARGET_DIR)

$(PKG_FINISH)
