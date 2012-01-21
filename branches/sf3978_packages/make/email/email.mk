$(call PKG_INIT_BIN, 3.1.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=a6f55ad946b4492b9ad05af0d5e4f1fe
$(PKG)_SITE:=http://www.cleancode.org/downloads/$(pkg)/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$(PKG)_DEPENDS_ON := openssl
$(PKG)_CFLAGS := -DEMAIL_VERSION='\"3.1.3\"' -DHAVE_CONFIG_H \
		 -DUSE_GNU_STRFTIME -DCOMPILE_DATE='\"10/31/2010-01:13:35PM_EDT\"' \
		 -I../dlib/include -I../include -I../dlib -I../dlib/src -I../src -I../ \
		 -DEMAIL_DIR='\"/tmp/flash/mod\"'

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(EMAIL_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(EMAIL_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(EMAIL_DIR) clean
	$(RM) $(EMAIL_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(EMAIL_BINARIES_TARGET_DIR)

$(PKG_FINISH)
