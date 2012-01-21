$(call PKG_INIT_BIN, 8.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=fce7999953a67243d00d75cc86dbcaa6
$(PKG)_SITE:=http://ftp.gnu.org/pub/gnu/$(pkg)/
$(PKG)_BINARIES:=base64 basename cat chcon chgrp chmod \
chown chroot cksum comm cp csplit cut date dd dir dircolors \
dirname du echo env expand expr factor false fmt fold groups \
head hostid id join kill link ln logname ls md5sum mkdir \
mkfifo mknod mktemp mv nice nl nohup od paste pathchk pinky pr \
printenv printf ptx pwd readlink rm rmdir runcon seq sha1sum \
sha224sum sha256sum sha384sum sha512sum shred shuf sleep \
sort split stat stdbuf stty sum sync tac tail tee test timeout \
touch tr true truncate tsort tty uname unexpand uniq unlink \
uptime users vdir wc who whoami yes [

$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_ENV += gl_cv_func_mbrtowc_incomplete_state=yes \
			gl_cv_func_mbrtowc_retval=yes \
			gl_cv_func_wcrtomb_retval=yes

$(PKG)_DEPENDS_ON := libpcap $(STDCXXLIB)
$(PKG)_CONFIGURE_ENV += LIBPREF="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --disable-acl \
			    --disable-assert \
			    --disable-rpath \
			    --disable-largefile \
			    --disable-xattr \
			    --without-libiconv-prefix \
			    --without-included-regex \
			    --without-gmp \
			    --without-libintl-prefix

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(COREUTILS_DIR)  \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -std=gnu99 -D_GNU_SOURCE -D__UCLIBC__"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(COREUTILS_DIR) clean
	$(RM) $(COREUTILS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(COREUTILS_BINARIES_TARGET_DIR)

$(PKG_FINISH)
