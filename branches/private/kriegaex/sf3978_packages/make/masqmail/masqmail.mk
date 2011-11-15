$(call PKG_INIT_BIN, 0.3.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=80a7f311ff0f680385eaf21d02889caa
$(PKG)_SITE:=http://marmaro.de/prog/$(pkg)/files/
$(PKG)_BINARIES:=$(pkg) mservdetect smtpsend
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_DEPENDS_ON += pcre glib2 gettext #openssl
# change the options if necessary!
$(PKG)_CONFIGURE_OPTIONS += --disable-debug \
			    --enable-auth \
			    --enable-ident \
			    --disable-option-checking \
			    --with-user=nobody \
			    --with-group=nobody \
			    --with-logdir=/var/media/ftp/uStor01/masqmail/log \
			    --with-spooldir=/var/media/ftp/uStor01/masqmail/spool \
			    --with-confdir=/var/tmp/masqmail \
			    --datadir=/var/media/ftp/uStor01/masqmail/share
# if with-libcrypto, then depends on openssl
#$(PKG)_CONFIGURE_OPTIONS += --with-libcrypto

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(MASQMAIL_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(MASQMAIL_DIR) clean
	$(RM) $(MASQMAIL_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(MASQMAIL_BINARIES_TARGET_DIR)

$(PKG_FINISH)
