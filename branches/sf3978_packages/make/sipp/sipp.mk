$(call PKG_INIT_BIN, svn)
$(PKG)_SOURCE:=$(pkg).$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=2a3a60cb4317dcf8eb5482f6a955e4d0
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg).$($(PKG)_VERSION)
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := ncurses $(STDCXXLIB)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(SIPP_DIR) \
		CC_linux="$(TARGET_CC)" \
		CPP_linux="$(TARGET_CXX)" \
		CCLINK_linux="$(TARGET_CC)" \
	        CFLAGS="$(TARGET_CFLAGS)" \
		CFLAGS_linux="$(TARGET_CFLAGS)" \
		CPPFLAGS_linux="$(TARGET_CFLAGS) -D__LINUX -pthread \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/uClibc++ \
		-fno-builtin -fno-rtti -nostdinc++ \
		-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/openssl" \
		LFLAGS_linux="$(TARGET_LDFLAGS)" \
		LIBS="-lncurses -ldl -lpthread -lm -luClibc++" \
		all

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(SIPP_DIR) clean
	 $(RM) $(SIPP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SIPP_TARGET_BINARY)
	$(RM) $(SIPP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
