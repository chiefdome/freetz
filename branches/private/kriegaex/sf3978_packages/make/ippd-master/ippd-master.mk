$(call PKG_INIT_BIN, 1.0.0)
$(PKG)_SOURCE:=$(pkg).tar.bz2
$(PKG)_SOURCE_MD5:=5e8c1ffdfa739a8e0f5b57acf93bb802
$(PKG)_SITE:=http://www.yaabou.com/cgit/ippd.git/snapshot/
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)
$(PKG)_BINARIES:=ippd
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXTRA_CFLAGS += -pedantic -std=gnu99 \
		  -Wall -Wunused -Wimplicit -Wshadow -Wformat=2 \
		  -Wno-missing-prototypes -Wwrite-strings \
		  -Wbad-function-cast -Wnested-externs -Wcomment -Winline \
		  -Wchar-subscripts -Wcast-align -Wno-format-nonliteral

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(IPPD_MASTER_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(IPPD_MASTER_EXTRA_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(IPPD_MASTER_DIR) clean
	$(RM) $(IPPD_MASTER_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IPPD_MASTER_BINARIES_TARGET_DIR)

$(PKG_FINISH)
