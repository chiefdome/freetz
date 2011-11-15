$(call PKG_INIT_BIN, 3.2.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=1ba0065ed50509aaffb171594c689f46
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_DEPENDS_ON := jpeg

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_LIBS := -lpthread -ljpeg -lm

$(PKG)_CONFIGURE_OPTIONS += --without-ffmpeg \
			    --without-jpeg-mmx \
			    --without-mysql \
			    --without-pgsql

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(MOTION_DIR) \
	LIBS="$(MOTION_LIBS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MOTION_DIR) clean
	$(RM) $(MOTION_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(MOTION_BINARIES_TARGET_DIR)

$(PKG_FINISH)
