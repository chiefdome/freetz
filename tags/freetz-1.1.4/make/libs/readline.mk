$(call PKG_INIT_LIB, 5.2)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.gnu.org/gnu/readline
$(PKG)_$(PKG)_BINARY:=$($(PKG)_DIR)/shlib/libreadline.so.$($(PKG)_LIB_VERSION)
$(PKG)_HISTORY_BINARY:=$($(PKG)_DIR)/shlib/libhistory.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_$(PKG)_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_HISTORY_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_$(PKG)_BINARY:=$($(PKG)_TARGET_DIR)/libreadline.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_HISTORY_BINARY:=$($(PKG)_TARGET_DIR)/libhistory.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_CONFIGURE_ENV += bash_cv_func_sigsetjmp=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_READLINE_BINARY) $($(PKG)_HISTORY_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(READLINE_DIR)

$($(PKG)_STAGING_READLINE_BINARY) $($(PKG)_STAGING_HISTORY_BINARY): \
		$($(PKG)_READLINE_BINARY) $($(PKG)_HISTORY_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(READLINE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_TARGET_READLINE_BINARY): $($(PKG)_STAGING_READLINE_BINARY)
	chmod 755 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline*.so* $(READLINE_TARGET_DIR)/
	$(TARGET_STRIP) $@
	
$($(PKG)_TARGET_HISTORY_BINARY):  $($(PKG)_STAGING_HISTORY_BINARY)
	chmod 755 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory*.so* $(READLINE_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_READLINE_BINARY) $($(PKG)_STAGING_HISTORY_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_READLINE_BINARY) \
					$($(PKG)_TARGET_HISTORY_BINARY)

$(pkg)-clean:
	$(MAKE) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" -C $(READLINE_DIR) uninstall
	-$(MAKE) -C $(READLINE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(READLINE_TARGET_DIR)/libreadline*.so*
	$(RM) $(READLINE_TARGET_DIR)/libhistory*.so*

$(PKG_FINISH)