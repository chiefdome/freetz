$(call PKG_INIT_BIN, 5.43)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/smartmontools
$(PKG)_SOURCE_MD5:=a1cb2c3d8cc2de377037fe9e7cef40a9

$(PKG)_BINARIES := smartctl
$(PKG)_BINARIES_BUILD_DIR := $(addprefix $($(PKG)_DIR)/,$($(PKG)_BINARIES))
$(PKG)_BINARIES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/usr/sbin/,$($(PKG)_BINARIES))

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SMARTMONTOOLS_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SMARTMONTOOLS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SMARTMONTOOLS_BINARIES_ALL:%=$(SMARTMONTOOLS_DEST_DIR)/usr/sbin/%)

$(PKG_FINISH)
